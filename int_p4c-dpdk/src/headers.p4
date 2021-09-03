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

const bit<16> ETHER_LEN  = 14;
const bit<16> IP_LEN     = 20;
const bit<16> UDP_LEN    = 8;
const bit<16> REPORT_LEN = 22;

// Following 2 fields must always have same value
const bit<8>    IPv4_DSCP_INT       = 0x20;
const bit<16>   IPv4_DSCP_INT_16    = 0x20;

const bit<8> DSCP_MASK = 0x3f;

const bit<8> INT_SHIM_HEADER_LEN_BYTES_8 = 6;
const bit<16> INT_SHIM_HEADER_LEN_BYTES = 6;

const bit<8> INT_TYPE_HOP_BY_HOP = 1;

const bit<8> INT_HEADER_LEN_BYTES_8 = 14;
const bit<16> INT_HEADER_LEN_BYTES = 14;

const bit<8> INT_VERSION = 1;
const bit<8> INT_REPORT_HEADER_LEN_WORDS = 4;

const bit<8> INT_ALL_HEADER_LEN_BYTES_8 = INT_SHIM_HEADER_LEN_BYTES_8 + INT_HEADER_LEN_BYTES_8;
const bit<16> INT_ALL_HEADER_LEN_BYTES = INT_SHIM_HEADER_LEN_BYTES + INT_HEADER_LEN_BYTES;

// Following 2 fields must always have same value
const bit<8>    MAX_HOP_8  = 04;
const bit<16>   MAX_HOP_16 = 04;

const bit<8> HOP_META_LEN = 6;
const bit<16> HOP_META_LEN_UPPER = 0x0600;
const bit<16> HOP_INFO = 0x0604;
//const bit<16> HOP_INFO = 0x0604; // Upper 8b corresponds to HOP_META_LEN lower 8b MAX_HOP
// Field is necesary for checksum computation.

// const bit<8> INSTRUCTION_MASK1 = 12;//0X0C;
// const bit<8> INSTRUCTION_MASK2 = 12;//0X0C;
const bit<16> INSTRUCTION_MASK_COMPLET = 0x00cc;//0x0c0c;//0x0c0c; // Upper 8b corresponds to INSTRUCTION_MASK1 lower 8b INSTRUCTION_MASK2
// Field is necesary for checksum computation.

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header ipv4_t {
    bit<8>  version_ihl;
    bit<8>  dscp;
    bit<16> totalLen;
    bit<16> id;
    bit<16>  flags_flagOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header udp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<16> len;
    bit<16> csum;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNum;
    bit<32> ackNum;
    bit<16> dataOffset_reserved_flags;
    bit<16> winSize;
    bit<16> csum;
    bit<16> urgPoint;
}

header intl4_shim_t {
    bit<8> int_type;
    bit<8> rsvd1;
    bit<8> len;     
    bit<8> dscp;   
    bit<8> rsvd3;    
    bit<8> padding;
}

header transit_int_header_t {
    bit<8>  ver;
    bit<8>  rep;                
    bit<16> c_e;                   
    bit<16> m_rsvd1;

    bit<16> rsvd2; 
    bit<16> hop_info;  

    bit<16> instruction_mask;   
    bit<16> rsvd3;
}

// Auxiliary header for checksum
// Not for emiting
header ck_helper_t {
    bit<16> old_udp_len;
    bit<8> old_shim_len;
    bit<16> old_hop;
    bit<16> old_dscp;
    bit<16> old_totalLen;

    bit<16> ipv4_dscp;
    bit<16> ipv4_protocol;
}
// unused
header int_header_t {
    bit<8>  ver;               
    bit<8>  rep;               
    bit<8>  c;                  
    bit<8>  e;                 
    bit<8>  m;                  
    bit<8>  rsvd1;             
    bit<16>  rsvd2;                
    bit<8>  hop_metadata_len;   
    
    bit<8>  remaining_hop_cnt; 
    bit<8>  instruction_mask1;      
    bit<8>  instruction_mask2;      
    bit<16> rsvd3;            
}

header int_switch_id_t {
    bit<32> switch_id;
}

header int_port_ids_t {
    PortId_t ingress_port_id;
    PortId_t egress_port_id;
}

header int_hop_latency_t {
    bit<32> hop_latency;
}

header int_q_occupancy_t {
    bit<8>  q_id;
    bit<24> q_occupancy;
}

header int_ingress_tstamp_t {
    Timestamp_t ingress_tstamp;
}

header int_egress_tstamp_t {
    bit<64> egress_tstamp;
}

header int_level2_port_ids_t {
    bit<16> ingress_port_id;
    bit<16> egress_port_id;
}

header int_egress_port_tx_util_t {
    bit<32> egress_port_tx_util;
}

// currently unused
header node_meta_t {
    bit<32> switch_id;
    bit<16> ingress_port_id;
    bit<16> egress_port_id;
    bit<64> ingress_tstamp;
    bit<64> egress_tstamp;
}
// currently unused
header influx_t {
    bit<32> srcAddr;
    bit<32> dstAddr;
    bit<16> ingress_port_id;
    bit<16> egress_port_id;
    bit<8> meta_len;
    bit<8> hop_meta_len;
    bit<16> rsvd1;
    bit<64> ndk_timestamp;
    bit<64> delay;
    bit<32> seq;
}

struct empty_metadata_t {
}

struct clone_i2e_metadata_t {
    // bit<8> custom_tag_M;
    // bit<48> srcAddr;
}

struct metadata_t {
    // int_metadata_t  int_metadata;
    bit<8>  source;                         // is INT source functionality enabled
    bit<8>  sink;                           // is INT sink functionality enabled
    bit<8>  remove_int;                     // indicator that all INT headers and data must be removed at egress for the processed packet 

    bit<32> switch_id;                      // INT switch id is configured by network controller
    bit<16> insert_byte_cnt;                // counter of inserted INT bytes
    bit<8>  int_hdr_word_len;               // counter of inserted INT words

    bit<8>  sink_reporting_port;            // on which port INT reports must be send to INT collector
    Timestamp_t ingress_tstamp;                 // pass ingress timestamp from Ingress pipeline to Egress pipeline
    PortId_t ingress_port;                   // pass ingress port from Ingress pipeline to Egress pipeline 

    bit<8>  dscp;                   
    
    bit<8> hops;
    bit<16> hops_16;
    bit<16> total_hops_len;
    bit<8> remove;

    bit<16> l4_src;
    bit<16> l4_dst;

    bit<16> mask;
}

header int_report_fixed_header_t {
    bit<8> ver;
    bit<8> len;
    bit<8> nprot;
    bit<8> rep_md_bits;
    bit<8> reserved;
    bit<8> d;
    bit<8> q;
    bit<8> f;
    bit<8> hw_id;
    bit<8> padding;
    bit<32> switch_id;
    bit<32> seq_num;
    Timestamp_t ingress_tstamp;
}

// header int_report_fixed_header_t {
    // bit<4> ver;
    // bit<4> len;
    // bit<3> nprot;
    // bit<6> rep_md_bits;
    // bit<6> reserved;
    // bit<1> d;
    // bit<1> q;
    // bit<1> f;
    // bit<6> hw_id;
    // bit<32> switch_id;
    // bit<32> seq_num;
    // bit<32> ingress_tstamp;
// }

struct headers_t {
    // INT report headers
    ethernet_t                  report_ethernet;
    ipv4_t                      report_ipv4;
    udp_t                       report_udp;
    int_report_fixed_header_t   report_fixed_header;

    // normal headers
    ethernet_t                  ethernet;
    ipv4_t                      ipv4;
    tcp_t                       tcp;
    udp_t                       udp;

    // INT headers
    intl4_shim_t                int_shim;
    int_header_t                int_header;
    transit_int_header_t        transit_int_header;
  
    // local INT node metadata
    int_switch_id_t             int_switch_id;
    int_port_ids_t              int_port_ids; 
    int_hop_latency_t           int_hop_latency;
    int_q_occupancy_t           int_q_occupancy;
    int_ingress_tstamp_t        int_ingress_tstamp;
    int_egress_tstamp_t         int_egress_tstamp;
    int_level2_port_ids_t       int_level2_port_ids;
    int_egress_port_tx_util_t   int_egress_port_tx_util;

    //sink
    influx_t                    influx;

    node_meta_t[MAX_HOP_8]      node_stack;

    ck_helper_t                 ck_helper;
}