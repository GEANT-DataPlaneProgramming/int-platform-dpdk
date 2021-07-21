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

const bit<16> MASK_CONST = 6;
const bit<16> X_CONST = 4;

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
        packet.extract(hdr.int_header);
        meta.hops = hdr.int_header.rsvd1 - hdr.int_header.remaining_hop_cnt; 
        meta.total_hops_len = 0;
        transition select(meta.hops) {
            0       : accept;
            default : parse_node_stack;
        }
    }

    state parse_node_stack {
        packet.extract(hdr.node_stack.next);
        meta.hops = meta.hops - 1;
        meta.total_hops_len = meta.total_hops_len + MASK_CONST*X_CONST; 
        transition select(meta.hops) {
            0       : accept;
            default : parse_node_stack;
        }
    }
}

control MyIngress(
    inout   headers_t                       hdr,
    inout   metadata_t                      meta,
    in      psa_ingress_input_metadata_t    standard_metadata,
    inout   psa_ingress_output_metadata_t   ostd
    ) {

    action send_raw() {
        hdr.influx.setValid();

        hdr.influx.seq = 0;
        hdr.influx.ingress_port_id = hdr.udp.srcPort;
        hdr.influx.egress_port_id  = hdr.udp.dstPort;

        hdr.influx.srcAddr = hdr.ipv4.srcAddr;
        hdr.influx.dstAddr = hdr.ipv4.dstAddr;
        hdr.influx.ndk_timestamp = 0;
        hdr.influx.delay = 0;
        hdr.influx.hop_meta_len = hdr.int_header.hop_metadata_len;
        hdr.influx.meta_len = hdr.int_shim.len;
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
    }

    table table_send_report {
        key = {
            hdr.ipv4.srcAddr : exact;
        }

        actions = {
            send_raw;
            remove_int;
        }
    }

    apply {
        if(hdr.int_header.isValid())
        {
            meta.remove = 0;
            table_send_report.apply();
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
        ck.subtract(hdr.ck_helper.old_dscp);
        ck.subtract(hdr.ck_helper.old_totalLen);

        ck.add({ 
            hdr.ck_helper.ipv4_dscp, 
            hdr.ipv4.totalLen
        });
        hdr.ipv4.hdrChecksum = ck.get();

        //~~~~~~~~~~~~~~~~~~~~~~~~~
        // UDP checksum
        //~~~~~~~~~~~~~~~~~~~~~~~~~
        if(hdr.int_header.isValid())
        {
            if(meta.remove == 1) {
                ck.clear();

                ck.subtract(hdr.int_header.rsvd3);

                ck.add({
                    hdr.udp.len,
                    hdr.udp.len
                });

                hdr.udp.csum = ck.get();

                packet.emit(hdr.ethernet);
                packet.emit(hdr.ipv4);
                packet.emit(hdr.udp);
            }
            else {
                packet.emit(hdr.influx); 
                packet.emit(hdr.node_stack);      
            }
        }
        else {
            packet.emit(hdr.ethernet);
            packet.emit(hdr.ipv4);
            packet.emit(hdr.udp);
        }
    }
}

parser MyEgressParser(
            packet_in                           packet, 
    out     headers_t                           hdr, 
    inout   metadata_t                          meta, 
    in      psa_egress_parser_input_metadata_t  istd, 
    in      empty_metadata_t                    normal_meta, 
    in      clone_i2e_metadata_t                clone_i2e_meta, 
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
    
    apply{}
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