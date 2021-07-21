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

#include "headers.p4"

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
            default: accept;
        }
    }

    state parse_udp {
        packet.extract(hdr.udp);
        transition select(meta.dscp) {
            8w0x20: parse_int_shim;
            default: accept;
        }
    }

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
    ) {
    // Configure parameters of INT transit node:
    // switch_id which is used within INT node metadata
    // l3_mtu is curently not used but should allow to detect condition if adding new INT metadata will exceed allowed MTU packet size
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
        //hdr.int_port_ids.ingress_port_id = (bit<16>)standard_metadata.ingress_port;
        hdr.int_port_ids.ingress_port_id = meta.ingress_port;
        hdr.int_port_ids.egress_port_id = 0xDEAD; //(bit<16>)standard_metadata.egress_port;
    }
    action int_set_header_2() {
        hdr.int_hop_latency.setValid();
        hdr.int_hop_latency.hop_latency = 42; //(bit<32>)(standard_metadata.egress_global_timestamp - meta.int_metadata.ingress_tstamp);
    }
    action int_set_header_3() {
        hdr.int_q_occupancy.setValid();
        hdr.int_q_occupancy.q_id = 0; // qid not defined in v1model
        hdr.int_q_occupancy.q_occupancy = 0x24B; //(bit<24>)standard_metadata.enq_qdepth;
    }
    action int_set_header_4() {
        hdr.int_ingress_tstamp.setValid();
        hdr.int_ingress_tstamp.ingress_tstamp = meta.ingress_tstamp + 1000; //convert us to ns
    }
    action int_set_header_5() {
        hdr.int_egress_tstamp.setValid();
        hdr.int_egress_tstamp.egress_tstamp = 0xFFFFABECEDACFFFF; //standard_metadata.egress_global_timestamp * 1000; //convert us to ns
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
            hdr.transit_int_header.instruction_mask1: exact;
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
            hdr.transit_int_header.instruction_mask2: exact;
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

    //---------------------------
    // APPLY
    //---------------------------
    apply {	
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
                tb_int_inst_0003.apply();
                tb_int_inst_0407.apply();

                // update length fields in IPv4, UDP and INT
                int_update_ipv4_ac();

                if (hdr.udp.isValid())
                    int_update_udp_ac();

                if (hdr.int_shim.isValid()) 
                    int_update_shim_ac();
            }
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
        ck.subtract(hdr.ck_helper.old_shim_len);
        ck.subtract(hdr.ck_helper.old_hop);

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
        
        // original headers
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.udp);
        
        // INT headers
        packet.emit(hdr.int_shim);
        packet.emit(hdr.transit_int_header);

        // local INT node metadata       
        packet.emit(hdr.int_switch_id);             
        packet.emit(hdr.int_port_ids);              
        packet.emit(hdr.int_hop_latency);
        packet.emit(hdr.int_q_occupancy);           
        packet.emit(hdr.int_ingress_tstamp);        
        packet.emit(hdr.int_egress_tstamp);         
        // packet.emit(hdr.int_level2_port_ids);    // Strange behavior witch this header, especiali when not valid
        packet.emit(hdr.int_egress_port_tx_util);   
    }
}

parser MyEgressParser(
            packet_in                           buffer, 
    out     headers_t                           hdr, 
    inout   metadata_t                          meta, 
    in      psa_egress_parser_input_metadata_t  istd, 
    in      empty_metadata_t                    normal_meta, 
    in      clone_i2e_metadata_t                     clone_i2e_meta, 
    in      empty_metadata_t                    clone_e2e_meta
    ) {
    state start {
        transition accept;
    }
}

control MyEgress(
    inout   headers_t                       hdr,
    inout   metadata_t                      meta,
    in      psa_egress_input_metadata_t     istd,
    inout   psa_egress_output_metadata_t    ostd
    ) {
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
    ) {
    apply {
    }
}

IngressPipeline(MyIngressParser(), MyIngress(), MyIngressDeparser()) ip;

EgressPipeline(MyEgressParser(), MyEgress(), MyEgressDeparser()) ep;

PSA_Switch(ip, PacketReplicationEngine(), ep, BufferingQueueingEngine()) main;