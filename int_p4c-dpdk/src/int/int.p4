/*
 * Copyright 2020 PSNC
 *
 * Author: Pavlína Patová
 *
 * Created in the GN4-3 project.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

 /////////////////////////////////////////////////////////////////////////////////////////////////////////
 
#include <core.p4>
#include <psa.p4>
#include "../headers.p4"

// 0 - TRANSIT
// 1 - SOURCE
const bit<8> SOURCE = 0;
const bit<8> SINK = 1;

parser MyIngressParser(packet_in packet,
                out     headers_t                               hdr,
                inout   metadata_t                              meta,
                in      psa_ingress_parser_input_metadata_t     standard_metadata,
                in      empty_metadata_t                        resub_meta,
                in      empty_metadata_t                        recirc_meta
                
    ) {
    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x800: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        meta.dscp = hdr.ipv4.dscp;
        transition select(hdr.ipv4.protocol) {
            8w0x11: parse_udp;
            8w0x6: parse_tcp;
            default: accept;
        }
    }

    state parse_udp {
        packet.extract(hdr.udp);
        meta.l4_src = hdr.udp.srcPort;
        meta.l4_dst = hdr.udp.dstPort;
        meta.dscp = meta.dscp & DSCP_MASK;
        transition select(meta.dscp) {
                        // 8w0x20: parse_aux;
            8w0x20: parse_int_shim;
            default: accept;
        }
    }

    state parse_tcp {
        packet.extract(hdr.tcp);
        meta.l4_src = hdr.tcp.srcPort;
        meta.l4_dst = hdr.tcp.dstPort;
        meta.dscp = meta.dscp & DSCP_MASK;
        transition select(meta.dscp) {
            // 8w0x20: parse_aux;
            8w0x20: parse_int_shim;
            default: accept;
        }
    }

    // state parse_aux { 
    //     // TODO, Bad mask
    //     transition select(meta.l4_dst) {
    //         0..1: parse_int_shim;
    //         16w0x2a:parse_int_shim; // For testing with packet udp_payload.pcap
    //         default: accept;
    //     }
    // }

    state parse_int_shim {
        packet.extract(hdr.int_shim);
        transition parse_int_header;
    }

    state parse_int_header {
        packet.extract(hdr.transit_int_header);
        transition accept;
    }
}



control MyIngress(
    inout   headers_t                       hdr,
    inout   metadata_t                      meta,
    in      psa_ingress_input_metadata_t    standard_metadata,
    inout   psa_ingress_output_metadata_t   ostd
    ) 
{

    // TRANSIT
         action configure_transit(bit<32> switch_id, bit<16> l3_mtu) {
            meta.switch_id = switch_id;
            meta.insert_byte_cnt = 0;
            meta.int_hdr_word_len = 0;
            // meta.l3_mtu = l3_mtu;
        }

        action default_transit_conf() {
            configure_transit(9, 1500);
        }

        // Table used to configure a switch as a INT transit
        // If INT transit configured then all packets with INT header will be precessed by INT transit logic
        table tb_int_transit {
            actions = {
                configure_transit;
                default_transit_conf;
            }
            
                
            
            default_action = default_transit_conf();
            //default_action = default_transit_conf();
        }

        //---------------------------
        // ADD HEADER
        //---------------------------
        action add_1() {                                                        // add(x)
            meta.int_hdr_word_len = meta.int_hdr_word_len + 1;     //x
            meta.insert_byte_cnt  = meta.insert_byte_cnt + 4;      // x*4
        }
        action add_2() {
            meta.int_hdr_word_len = meta.int_hdr_word_len + 2;
            meta.insert_byte_cnt  = meta.insert_byte_cnt + 8;
        }
        action add_3() {
            meta.int_hdr_word_len = meta.int_hdr_word_len + 3;
            meta.insert_byte_cnt  = meta.insert_byte_cnt + 12;
        }
        action add_4() {
            meta.int_hdr_word_len = meta.int_hdr_word_len + 4;
            meta.insert_byte_cnt  = meta.insert_byte_cnt + 16;
        }
        action add_5() {
            meta.int_hdr_word_len = meta.int_hdr_word_len + 5;
            meta.insert_byte_cnt  = meta.insert_byte_cnt + 20;
        }
        action add_6() {
            meta.int_hdr_word_len = meta.int_hdr_word_len + 6;
            meta.insert_byte_cnt  = meta.insert_byte_cnt + 24;
        }

        //---------------------------
        // SET HEADER
        //---------------------------

        // hdr.int_switch_id     0
        // hdr.int_port_ids       1
        // hdr.int_hop_latency    2
        // hdr.int_q_occupancy    3
        // hdr.int_ingress_tstamp  4
        // hdr.int_egress_tstamp   5
        // hdr.int_level2_port_ids   6
        // hdr.int_egress_port_tx_util   7

        // Note, some data are replaced by constants because compiler/interpret does not support all required operations
        action int_set_header_0() {
            hdr.int_switch_id.setValid();
            hdr.int_switch_id.switch_id = meta.switch_id;
        }
        action int_set_header_1() {
            hdr.int_port_ids.setValid();
            hdr.int_port_ids.ingress_port_id = meta.ingress_port;
            hdr.int_port_ids.egress_port_id = ostd.egress_port;
        }
        action int_set_header_2() {
            hdr.int_hop_latency.setValid();
            hdr.int_hop_latency.hop_latency = 0; //(bit<32>)(standard_metadata.egress_global_timestamp - meta.int_metadata.ingress_tstamp);
        }
        action int_set_header_3() {
            hdr.int_q_occupancy.setValid();
            hdr.int_q_occupancy.q_id = 0; // qid not defined in v1model
            hdr.int_q_occupancy.q_occupancy = 0; //(bit<24>)standard_metadata.enq_qdepth;
        }
        action int_set_header_4() {
            hdr.int_ingress_tstamp.setValid();
            hdr.int_ingress_tstamp.ingress_tstamp = meta.ingress_tstamp; //* 1000; //convert us to ns
        }
        action int_set_header_5() {
            hdr.int_egress_tstamp.setValid();
            hdr.int_egress_tstamp.egress_tstamp = 0; //standard_metadata.egress_global_timestamp * 1000; //convert us to ns
        }
        action int_set_header_6() {
            hdr.int_level2_port_ids.setValid();
            // no such metadata in v1model
            hdr.int_level2_port_ids.ingress_port_id = 0;
            hdr.int_level2_port_ids.egress_port_id = 0;
        }
        action int_set_header_7() {
            hdr.int_egress_port_tx_util.setValid();
            // no such metadata in v1model
            hdr.int_egress_port_tx_util.egress_port_tx_util = 0;
        }

        //---------------------------
        // HEADER 0003
        //---------------------------

        action int_set_header_0003_i0() {
            ;
        }
        action int_set_header_0003_i1() {
            int_set_header_3();
            add_1();
        }
        action int_set_header_0003_i2() {
            int_set_header_2();
            add_1();
        }
        action int_set_header_0003_i3() {
            int_set_header_5();
            int_set_header_2();
            add_3();
        }
        action int_set_header_0003_i4() {
            int_set_header_1();
            add_1();
        }
        action int_set_header_0003_i5() {
            int_set_header_3();
            int_set_header_1();
            add_2();
        }
        action int_set_header_0003_i6() {
            int_set_header_2();
            int_set_header_1();
            add_2();
        }
        action int_set_header_0003_i7() {
            int_set_header_3();
            int_set_header_2();
            int_set_header_1();
            add_3();
        }
        action int_set_header_0003_i8() {
            int_set_header_0();
            add_1();
        }
        action int_set_header_0003_i9() {
            int_set_header_3();
            int_set_header_0();
            add_2();
        }
        action int_set_header_0003_i10() {
            int_set_header_2();
            int_set_header_0();
            add_2();
        }
        action int_set_header_0003_i11() {
            int_set_header_3();
            int_set_header_2();
            int_set_header_0();
            add_3();
        }
        action int_set_header_0003_i12() {
            int_set_header_1();
            int_set_header_0();
            add_2();
        }
        action int_set_header_0003_i13() {
            int_set_header_3();
            int_set_header_1();
            int_set_header_0();
            add_3();
        }
        action int_set_header_0003_i14() {
            int_set_header_2();
            int_set_header_1();
            int_set_header_0();
            add_3();
        }
        action int_set_header_0003_i15() {
            int_set_header_3();
            int_set_header_2();
            int_set_header_1();
            int_set_header_0();
            add_4();
        }

        // Upper bit
        table tb_int_inst_0003 {
            actions = {
                int_set_header_0003_i0;
                int_set_header_0003_i1;
                int_set_header_0003_i2;
                int_set_header_0003_i3;
                int_set_header_0003_i4;
                int_set_header_0003_i5;
                int_set_header_0003_i6;
                int_set_header_0003_i7;
                int_set_header_0003_i8;
                int_set_header_0003_i9;
                int_set_header_0003_i10;
                int_set_header_0003_i11;
                int_set_header_0003_i12;
                int_set_header_0003_i13;
                int_set_header_0003_i14;
                int_set_header_0003_i15;
            }
            key = {
                meta.mask: exact;
            }
        }

        //---------------------------
        // HEADER 0407
        //---------------------------
        action int_set_header_0407_i0() {
            ;
        }    
        action int_set_header_0407_i1() {
            int_set_header_7();
            add_1();
        }
        action int_set_header_0407_i2() {
            int_set_header_6();
            add_1();
        }
        action int_set_header_0407_i3() {
            int_set_header_7();
            int_set_header_6();
            add_2();

        }
        action int_set_header_0407_i4() {
            int_set_header_5();
            add_2();
        }
        action int_set_header_0407_i5() {
            int_set_header_7();
            int_set_header_5();
            add_3();
        }
        action int_set_header_0407_i6() {
            int_set_header_6();
            int_set_header_5();
            add_3();
        }
        action int_set_header_0407_i7() {
            int_set_header_7();
            int_set_header_6();
            int_set_header_5();
            add_4();
        }
        action int_set_header_0407_i8() {
            int_set_header_4();
            add_2();
        }
        action int_set_header_0407_i9() {
            int_set_header_7();
            int_set_header_4();
            add_3();
        }
        action int_set_header_0407_i10() {
            int_set_header_6();
            int_set_header_4();
            add_3();
        }
        action int_set_header_0407_i11() {
            int_set_header_7();
            int_set_header_6();
            int_set_header_4();
            add_4();
        }
        action int_set_header_0407_i12() {
            int_set_header_5();
            int_set_header_4();
            add_4();
        }
        action int_set_header_0407_i13() {
            int_set_header_7();
            int_set_header_5();
            int_set_header_4();
            add_5();
        }
        action int_set_header_0407_i14() {
            int_set_header_6();
            int_set_header_5();
            int_set_header_4();
            add_5();
        }
        action int_set_header_0407_i15() {
            int_set_header_7();
            int_set_header_6();
            int_set_header_5();
            int_set_header_4();
            add_6();
        }

        // Lower bit
        table tb_int_inst_0407 {
            actions = {
                int_set_header_0407_i0;
                int_set_header_0407_i1;
                int_set_header_0407_i2;
                int_set_header_0407_i3;
                int_set_header_0407_i4;
                int_set_header_0407_i5;
                int_set_header_0407_i6;
                int_set_header_0407_i7;
                int_set_header_0407_i8;
                int_set_header_0407_i9;
                int_set_header_0407_i10;
                int_set_header_0407_i11;
                int_set_header_0407_i12;
                int_set_header_0407_i13;
                int_set_header_0407_i14;
                int_set_header_0407_i15;
            }
            key = {
                meta.mask: exact;
            }
        }

        action int_hop_cnt_increment() {
            hdr.transit_int_header.hop_info = hdr.transit_int_header.hop_info - 1;
        }

        action int_update_ipv4_ac() {
            hdr.ipv4.totalLen = hdr.ipv4.totalLen + meta.insert_byte_cnt;
        }

        action int_update_shim_ac() {
            hdr.int_shim.len = hdr.int_shim.len + meta.int_hdr_word_len;
        }

        action int_update_udp_ac() {
            hdr.udp.len = hdr.udp.len + meta.insert_byte_cnt;
        }
    // TRANSIT
    
    action int_hop_exceeded() {
            // We assume that c and e are originaly only 1 bit wide so thes condition should be ok (both values can be either 0 or 1)
            // Also these two fields are merget for better cksum computation
            if(hdr.transit_int_header.c_e == 0x0000 || hdr.transit_int_header.c_e == 0x0100)
                hdr.transit_int_header.c_e = hdr.transit_int_header.c_e + 0x0001;
        }

    action test_update_addresses() {
        hdr.ethernet.dstAddr =  0xffffffffffff;
    }

    // SOURCE
        action configure_source(
            bit<16> hop_metadata_len_max_hop, 
            //bit<16> ins_mask,
            // bit<8> ins_mask1,
            // bit<8> ins_mask2
            bit<16> ins_mask
        ) 
        {
            hdr.transit_int_header.setValid();
            hdr.ck_helper.setValid();
            hdr.int_shim.setValid();

            hdr.ck_helper.old_udp_len = hdr.udp.len;
            hdr.ck_helper.old_dscp = 0;
            hdr.ck_helper.old_totalLen = hdr.ipv4.totalLen;

            hdr.int_shim.int_type = INT_TYPE_HOP_BY_HOP;
            hdr.int_shim.len = INT_ALL_HEADER_LEN_BYTES_8>>2; //3;

            hdr.transit_int_header.ver = INT_VERSION;
            hdr.transit_int_header.rep = 0;
            hdr.transit_int_header.c_e = 0;
            hdr.transit_int_header.m_rsvd1 = 0;
            hdr.transit_int_header.rsvd2 = 0;
            hdr.transit_int_header.rsvd3 = 0;

            hdr.transit_int_header.hop_info = hop_metadata_len_max_hop;

            hdr.transit_int_header.instruction_mask = ins_mask;

            hdr.int_shim.dscp = hdr.ipv4.dscp;
            hdr.ipv4.dscp = IPv4_DSCP_INT;
            hdr.ipv4.totalLen = hdr.ipv4.totalLen + INT_ALL_HEADER_LEN_BYTES;  // adding size of INT headers

            hdr.udp.len = hdr.udp.len + INT_ALL_HEADER_LEN_BYTES;

            hdr.ck_helper.ipv4_protocol = 0x11;
            hdr.ck_helper.ipv4_dscp = IPv4_DSCP_INT_16;
        }

        action default_conf()
        {
            configure_source(HOP_INFO, INSTRUCTION_MASK_COMPLET);
        }

        // INT source must be configured per each flow which must be monitored using INT
        // Flow is defined by src IP, dst IP, src TCP/UDP port, dst TCP/UDP port 
        // When INT source configured for a flow then a node adds INT shim header and first INT node metadata headers
        table tb_int_source {
        actions = {
            configure_source;
            default_conf;
        }
        key = {
            hdr.ipv4.srcAddr     : exact;             
            hdr.ipv4.dstAddr     : exact;
            // meta.l4_src: exact;                      // Currently only one header can be present (interpret error)
            // meta.l4_dst: exact;
        }
        size = 127;
        
                
            
            default_action = default_conf();
        // default_action = default_conf();
        }
    // SOURCE
Register<bit<32>, bit<32>>(1)
        report_seq_num_register;

    // SINK
        action send_report(bit<48> dp_mac, bit<32> dp_ip, bit<48> collector_mac, bit<32> collector_ip, bit<16> collector_port) {
            // Ethernet **********************************************************
            hdr.report_ethernet.setValid();
            hdr.report_ethernet.dstAddr = collector_mac;
            hdr.report_ethernet.srcAddr = dp_mac;
            hdr.report_ethernet.etherType = 0x0800;

            // IPv4 **************************************************************
            hdr.report_ipv4.setValid();
            hdr.report_ipv4.version_ihl = 0x45;
            hdr.report_ipv4.dscp = 0;

            // TODO
            // Wont work bcs this way we are considering payload which we want to get rid of
            // but since truncate doesnt work we actualy need to use this for cksum computation
            hdr.report_ipv4.totalLen = hdr.ipv4.totalLen + ETHER_LEN + IP_LEN + UDP_LEN + REPORT_LEN;

            // TODO
            // add size of original tcp/udp header
            // if (hdr.tcp.isValid()) {
                // hdr.report_ipv4.totalLen = hdr.report_ipv4.totalLen
                    // + (((bit<16>)hdr.tcp.dataOffset) << 2);

            // } else {
                // hdr.report_ipv4.totalLen = hdr.report_ipv4.totalLen + 8;
            // }

            hdr.report_ipv4.id = 0;
            hdr.report_ipv4.flags_flagOffset = 0;
            hdr.report_ipv4.ttl = 64;
            hdr.report_ipv4.protocol = 17; // UDP
            hdr.report_ipv4.srcAddr = dp_ip;
            hdr.report_ipv4.dstAddr = collector_ip;

            // UDP ***************************************************************
            hdr.report_udp.setValid();
            hdr.report_udp.srcPort = 0;
            hdr.report_udp.dstPort = collector_port;
            hdr.report_udp.len = hdr.report_ipv4.totalLen - 20; 

            // INT report fixed header ************************************************/
            // INT report version 1.0
            hdr.report_fixed_header.setValid();
            hdr.report_fixed_header.ver = INT_VERSION;
            hdr.report_fixed_header.len = INT_REPORT_HEADER_LEN_WORDS;

            hdr.report_fixed_header.nprot = 0; // 0 for Ethernet
            hdr.report_fixed_header.rep_md_bits = 0;
            hdr.report_fixed_header.reserved = 0;
            hdr.report_fixed_header.d = 0;
            hdr.report_fixed_header.q = 0;
            // f - indicates that report is for tracked flow, INT data is present
            hdr.report_fixed_header.f = 1;
            // hw_id - specific to the switch, e.g. id of linecard
            hdr.report_fixed_header.hw_id = 0;
            hdr.report_fixed_header.switch_id = meta.switch_id; // meta.switch_id is set in transit config
            
            // TODO
            // missing, badly generated + doesn't work anyway

            bit<32> seq_num_value;
            seq_num_value = report_seq_num_register.read(0);
            hdr.report_fixed_header.seq_num = seq_num_value;
            report_seq_num_register.write(0, seq_num_value + 1);

            // TODO
            hdr.report_fixed_header.ingress_tstamp = standard_metadata.ingress_timestamp;
        }

        action remove_int() {
            meta.remove = 1;
            hdr.ck_helper.setValid();
            hdr.ck_helper.old_udp_len = hdr.udp.len;
            hdr.ck_helper.old_totalLen = hdr.ipv4.totalLen;
            hdr.ck_helper.old_dscp = IPv4_DSCP_INT_16;
            hdr.ck_helper.ipv4_dscp = 0;

            hdr.ipv4.dscp = hdr.int_shim.dscp;

            hdr.ipv4.totalLen = hdr.ipv4.totalLen - INT_ALL_HEADER_LEN_BYTES - meta.total_hops_len;
            hdr.udp.len = hdr.ipv4.totalLen - INT_ALL_HEADER_LEN_BYTES;

            hdr.int_switch_id.setInvalid();
            hdr.int_port_ids.setInvalid();
            hdr.int_ingress_tstamp.setInvalid();
            hdr.int_egress_tstamp.setInvalid();
            hdr.int_hop_latency.setInvalid();
            hdr.int_level2_port_ids.setInvalid();
            hdr.int_q_occupancy.setInvalid();
            hdr.int_egress_port_tx_util.setInvalid();

            // remove int data
            hdr.int_shim.setInvalid();
            hdr.transit_int_header.setInvalid();
        }

        action def_action() {
            // Some random values for testing
            send_report(0xcccccccccccc, 0xc0aabbcc, 0xbbbbbbbbbbbb, 0xc0aabbdd, 17000);
        }
    
        table table_sink_config {
            key = {
                hdr.udp.srcPort : exact;
            }

            actions = {
                send_report;
                remove_int;
                def_action;
            }
            
                
            
            default_action = def_action();
        }   
    // SINK

    // FORWARD
        action send_to_cpu(PortId_t port) {
            ostd.egress_port = port;
        }
        action send_to_port_custom(PortId_t port) {
            ostd.egress_port = port;
        }

        table tb_forward {
            actions = {
                send_to_cpu;
                send_to_port_custom;
            }
            key = {
                hdr.ethernet.dstAddr: exact;
            }
        }
    // FORWARD

    // PORT_FORWARD
        action send(PortId_t port) {
            ostd.egress_port = port;
        }

        table tb_port_forward {
            actions = {
                send;
            }
            key = {
                ostd.egress_port: exact;
            }
        }
    // PORT_FORWARD

    apply {
        if (hdr.udp.isValid() || hdr.tcp.isValid()) {
            // SOURCE

                // in case of frame clone for the INT sink reporting
                // ingress timestamp is not available on Egress pipeline
                meta.ingress_tstamp = standard_metadata.ingress_timestamp;//0x0;
                meta.ingress_port = standard_metadata.ingress_port;

                //check if packet appeard on ingress port with active INT source

                if (SOURCE == 8w1)      //1w1
                    //apply INT source logic on INT monitored flow
                    tb_int_source.apply();
            // SOURCE

            // FORWARD
                tb_forward.apply();
                tb_port_forward.apply();
            // FORWARD

            // TRANSIT
                hdr.ck_helper.setValid();
                hdr.ck_helper.old_udp_len = hdr.udp.len;
                hdr.ck_helper.old_shim_len = hdr.int_shim.len;
                hdr.ck_helper.old_hop = hdr.transit_int_header.hop_info;
                hdr.ck_helper.old_totalLen = hdr.ipv4.totalLen;

                if(hdr.transit_int_header.isValid()) {
                    if(hdr.transit_int_header.hop_info != HOP_INFO - MAX_HOP_16) {
                        int_hop_cnt_increment();

                        // add INT node metadata headers based on INT instruction_mask
                        tb_int_transit.apply();

                        meta.mask = hdr.transit_int_header.instruction_mask & 0x00F0;
                        tb_int_inst_0003.apply();

                        meta.mask = hdr.transit_int_header.instruction_mask & 0x000F;
                        tb_int_inst_0407.apply();

                        // update length fields in IPv4, UDP and INT
                        int_update_ipv4_ac();

                        if (hdr.udp.isValid())
                            int_update_udp_ac();

                        if (hdr.int_shim.isValid()) 
                            int_update_shim_ac();
                    }
                    else {
                        int_hop_exceeded();
                    }
                    
                }
            // TRANSIT

            // SINK 
                if (SINK == 8w1) {
                    if(hdr.transit_int_header.isValid())
                    {
                        meta.remove = 0;
                        table_sink_config.apply();
                    }
                }
            // SINK
        }
    }
}

control MyIngressDeparser(
            packet_out                      packet, 
    out     clone_i2e_metadata_t            clone_i2e_meta, 
    out     empty_metadata_t                resubmit_meta, 
    out     empty_metadata_t                normal_meta, 
    inout   headers_t                       hdr, 
    in      metadata_t                      meta, 
    in      psa_ingress_output_metadata_t   istd
    ) {

    InternetChecksum() ck;
    apply {
        //~~~~~~~~~~~~~~~~~~~~~~~~~
        // IPv4 checksum
        //~~~~~~~~~~~~~~~~~~~~~~~~~
        ck.clear();

        ck.subtract(hdr.ipv4.hdrChecksum);
        ck.subtract(hdr.ck_helper.old_totalLen);

        if(SOURCE == 8w1) {
            ck.subtract(hdr.ck_helper.old_dscp);

            ck.add({ 
                hdr.ck_helper.ipv4_dscp 
            });       
        }

        ck.add({ 
                hdr.ipv4.totalLen
            });

        hdr.ipv4.hdrChecksum = ck.get();


        //~~~~~~~~~~~~~~~~~~~~~~~~~
        // UDP checksum
        //~~~~~~~~~~~~~~~~~~~~~~~~~
        ck.clear();

        ck.subtract(hdr.udp.csum);
        ck.subtract(hdr.ck_helper.old_udp_len);
        ck.subtract(hdr.ck_helper.old_udp_len);

        if(SOURCE == 8w1) {
              
            hdr.transit_int_header.rsvd3 = ck.get();

            ck.add({
                hdr.int_shim.int_type,
                hdr.int_shim.rsvd1,
                hdr.int_shim.dscp,
                hdr.int_shim.rsvd3,

                hdr.transit_int_header.ver,
                hdr.transit_int_header.rep,
                hdr.transit_int_header.c_e,
                hdr.transit_int_header.m_rsvd1,
                hdr.transit_int_header.rsvd2,
                hdr.transit_int_header.hop_info,
                hdr.transit_int_header.instruction_mask,
                hdr.transit_int_header.rsvd3
            });
        }
        else {
            ck.subtract(hdr.ck_helper.old_shim_len);
            ck.subtract(hdr.ck_helper.old_hop);
        }

        ck.add({
            hdr.udp.len,
            hdr.udp.len,
            hdr.int_shim.len,
            hdr.transit_int_header.hop_info,
            hdr.int_switch_id.switch_id,
            hdr.int_port_ids.ingress_port_id,
            hdr.int_port_ids.egress_port_id,
            hdr.int_hop_latency.hop_latency,
            hdr.int_q_occupancy.q_id,
            hdr.int_q_occupancy.q_occupancy,
            hdr.int_ingress_tstamp.ingress_tstamp,
            hdr.int_egress_tstamp.egress_tstamp,
            hdr.int_level2_port_ids.ingress_port_id,
            hdr.int_level2_port_ids.egress_port_id,
            hdr.int_egress_port_tx_util.egress_port_tx_util
        });
    
        hdr.udp.csum = ck.get();
        // report headers
        if(hdr.transit_int_header.isValid())
        {
            if(SINK == 8w1) { 
                packet.emit(hdr.report_ethernet);
                packet.emit(hdr.report_ipv4);
                packet.emit(hdr.report_udp);
                packet.emit(hdr.report_fixed_header);
            }
        }

        // original headers
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        if(hdr.udp.isValid())
            packet.emit(hdr.udp);
        if(hdr.tcp.isValid())        
            packet.emit(hdr.tcp);

        // INT headers
        packet.emit(hdr.int_shim);
        packet.emit(hdr.transit_int_header);
        packet.emit(hdr.int_switch_id);             
        packet.emit(hdr.int_port_ids);              
        packet.emit(hdr.int_hop_latency);
        packet.emit(hdr.int_q_occupancy);           
        packet.emit(hdr.int_ingress_tstamp);        
        packet.emit(hdr.int_egress_tstamp);         
        packet.emit(hdr.int_level2_port_ids);    // Strange behavior witch this header, especiali when not valid
        packet.emit(hdr.int_egress_port_tx_util); 
    }
}

parser MyEgressParser(
            packet_in                           buffer, 
    out     headers_t                           hdr, 
    inout   metadata_t                          meta, 
    in      psa_egress_parser_input_metadata_t  istd, 
    in      empty_metadata_t                    normal_meta, 
    in      clone_i2e_metadata_t                clone_i2e_meta, 
    in      empty_metadata_t                    clone_e2e_meta
    )
{
    state start {
        transition accept;
    }
}

control MyEgress(
    inout   headers_t                       hdr,
    inout   metadata_t                      meta,
    in      psa_egress_input_metadata_t     istd,
    inout   psa_egress_output_metadata_t    ostd
) 
{
    apply {  }
}

control MyEgressDeparser(
            packet_out                              packet, 
    out     empty_metadata_t                        clone_e2e_meta, 
    out     empty_metadata_t                        recirculate_meta, 
    inout   headers_t                               hdr, 
    in      metadata_t                              meta, 
    in      psa_egress_output_metadata_t            istd, 
    in      psa_egress_deparser_input_metadata_t    edstd
) 
{
    apply {
    }
}

IngressPipeline(MyIngressParser(), MyIngress(), MyIngressDeparser()) ip;

EgressPipeline(MyEgressParser(), MyEgress(), MyEgressDeparser()) ep;

PSA_Switch(ip, PacketReplicationEngine(), ep, BufferingQueueingEngine()) main;