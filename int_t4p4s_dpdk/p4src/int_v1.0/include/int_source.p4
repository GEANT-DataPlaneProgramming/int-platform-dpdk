/*
 * Copyright 2020 PSNC
 *
 * Author: Mário Kuka
 *
 * Created in the GN4-3 project.
 *
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

control Int_source(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    action configure_source() {
        hdr.int_shim.setValid();
        hdr.int_shim.int_type = INT_TYPE_HOP_BY_HOP;
        hdr.int_shim.len = (bit<8>)INT_ALL_HEADER_LEN_BYTES>>2;
        
        hdr.int_header.setValid();
        hdr.int_header.ver = INT_VERSION;
        hdr.int_header.rep = 0;
        hdr.int_header.c = 0;
        hdr.int_header.e = 0;
        hdr.int_header.rsvd1 = 0;
        hdr.int_header.rsvd2 = 0;
        hdr.int_header.hop_metadata_len = 0x06;
        hdr.int_header.remaining_hop_cnt = 0xff;  // will be decreased immediately by 1 within transit process
        hdr.int_header.instruction_mask = 0x00cc; 
        
        hdr.int_shim.dscp = hdr.ipv4.dscp;
        
        hdr.ipv4.dscp = IPv4_DSCP_INT;   // indicates that INT header in the packet
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + INT_ALL_HEADER_LEN_BYTES;  // adding size of INT headers
        
        hdr.udp.len = hdr.udp.len + INT_ALL_HEADER_LEN_BYTES;
    }
    
    // INT source must be configured per each flow which must be monitored using INT
    // Flow is defined by src IP, dst IP, src TCP/UDP port, dst TCP/UDP port 
    // When INT source configured for a flow then a node adds INT shim header and first INT node metadata headers
    table tb_int_source {
        actions = {
            configure_source;
        }
        key = {
            hdr.ipv4.srcAddr     : ternary;
            hdr.ipv4.dstAddr     : ternary;
            meta.layer34_metadata.l4_src: ternary;
            meta.layer34_metadata.l4_dst: ternary;
        }
        size = 128;
        default_action = configure_source();
        //const entries = {
            // Example for: srcAddr = 0.0.0.0/32, dstAddr = 0.0.0.0/32, l4_sport = 0/16, l4_dport = 0/16
            //(0x00000000 &&& 0xffffffff, 0x00000000 &&& 0xffffffff, 0x0000 &&& 0xffff, 0x0000 &&& 0xffff) : configure_source();
        //}
    }

    apply {
        if (SRC_ENABLE)      
            tb_int_source.apply();
    }
}

