/*
 * Copyright 2020 PSNC
 *
 * Author: Mário Kuka
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

control Int_transit(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    action int_set_header_0() {
        hdr.int_switch_id.setValid();
        hdr.int_switch_id.switch_id = SWITCH_ID;
    }
    action int_set_header_1() {
        hdr.int_port_ids.setValid();
        hdr.int_port_ids.ingress_port_id = (bit<16>)standard_metadata.ingress_port;
        hdr.int_port_ids.egress_port_id = (bit<16>)standard_metadata.egress_port;
    }
    action int_set_header_2() {
        hdr.int_hop_latency.setValid();
        hdr.int_hop_latency.hop_latency = 0; //(bit<32>)(standard_metadata.egress_global_timestamp - meta.int_metadata.ingress_tstamp);
    }
    action int_set_header_3() {
        hdr.int_q_occupancy.setValid();
        hdr.int_q_occupancy.q_id = 0; // qid not defined in v1model
        hdr.int_q_occupancy.q_occupancy = (bit<24>)standard_metadata.enq_qdepth;
    }
    action int_set_header_4() {
        hdr.int_ingress_tstamp.setValid();
        hdr.int_ingress_tstamp.ingress_tstamp = 0; //meta.int_metadata.ingress_tstamp * 1000; //convert us to ns
    }
    action int_set_header_5() {
        hdr.int_egress_tstamp.setValid();
        hdr.int_egress_tstamp.egress_tstamp = 0; //standard_metadata.egress_global_timestamp * 1000; //convert us to ns
    }
    action int_set_header_6() {
        hdr.int_level2_port_ids.setValid();
        hdr.int_level2_port_ids.ingress_port_id = 0;
        hdr.int_level2_port_ids.egress_port_id = 0;
    }
    action int_set_header_7() {
        hdr.int_egress_port_tx_util.setValid();
        hdr.int_egress_port_tx_util.egress_port_tx_util = 0;
    }

    action int_hop_cnt_increment() {
        hdr.int_header.remaining_hop_cnt = hdr.int_header.remaining_hop_cnt - 1;
    }
    action int_hop_exceeded() {
        hdr.int_header.e = 1w1;
    }

    //action int_update_ipv4_ac() {
    //    hdr.ipv4.totalLen = hdr.ipv4.totalLen + (bit<16>)meta.int_metadata.insert_byte_cnt;
    //}
    //action int_update_shim_ac() {
    //    hdr.int_shim.len = hdr.int_shim.len + (bit<8>)meta.int_metadata.int_hdr_word_len;
    //}
    //action int_update_udp_ac() {
    //    hdr.udp.len = hdr.udp.len + (bit<16>)meta.int_metadata.insert_byte_cnt;
    //}

    apply {	
        // INT transit must process only INT packets
        if (!hdr.int_header.isValid())
            return;
    
        int_set_header_0();
        int_set_header_1();
        int_set_header_4();
        int_set_header_5();     
  
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 24;
        hdr.udp.len = hdr.udp.len + 24;
        hdr.int_shim.len = hdr.int_shim.len + 6;
        
        int_hop_cnt_increment();
    }
}
