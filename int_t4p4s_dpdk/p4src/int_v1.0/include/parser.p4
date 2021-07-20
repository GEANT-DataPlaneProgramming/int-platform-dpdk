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

error
{
	INTShimLenTooShort,
	INTVersionNotSupported
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
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
        meta.layer34_metadata.dscp = hdr.ipv4.dscp;
        transition select(hdr.ipv4.protocol) {
            8w0x11: parse_udp;
            8w0x6: parse_tcp;
            default: accept;
        }
    }
    state parse_tcp {
        packet.extract(hdr.tcp);
        meta.layer34_metadata.l4_src = hdr.tcp.srcPort;
        meta.layer34_metadata.l4_dst = hdr.tcp.dstPort;
        transition select(meta.layer34_metadata.dscp) {
            IPv4_DSCP_INT: parse_int_shim;
            default: accept;
        }
    }
    state parse_udp {
        packet.extract(hdr.udp);
        meta.layer34_metadata.l4_src = hdr.udp.srcPort;
        meta.layer34_metadata.l4_dst = hdr.udp.dstPort;
        transition select(meta.layer34_metadata.dscp) {
            IPv4_DSCP_INT: parse_int_shim;
            default: accept;
        }
    }
    state parse_int_shim {
        packet.extract(hdr.int_shim);
        verify(hdr.int_shim.len >= 3, error.INTShimLenTooShort);
        transition parse_int_header;
    }
    state parse_int_header {
        packet.extract(hdr.int_header);
        verify(hdr.int_header.ver == INT_VERSION, error.INTVersionNotSupported);
        transition accept;
    }
}


control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        // original headers
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.udp);
        packet.emit(hdr.tcp);
        
        // INT headers
        packet.emit(hdr.int_shim);
        packet.emit(hdr.int_header);
        
        // local INT node metadata
        packet.emit(hdr.int_switch_id);           // bit 1
        packet.emit(hdr.int_port_ids);            // bit 2
        packet.emit(hdr.int_hop_latency);         // bit 3
        packet.emit(hdr.int_q_occupancy);         // bit 4
        packet.emit(hdr.int_ingress_tstamp);      // bit 5
        packet.emit(hdr.int_egress_tstamp);       // bit 6
        packet.emit(hdr.int_level2_port_ids);     // bit 7
        packet.emit(hdr.int_egress_port_tx_util); // bit 8
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

