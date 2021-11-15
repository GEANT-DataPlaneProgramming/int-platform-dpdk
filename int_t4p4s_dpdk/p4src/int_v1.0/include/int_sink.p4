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

control Int_sink(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    action fill_influx() {
        hdr.influx.srcAddr = hdr.ipv4.srcAddr;
        hdr.influx.dstAddr = hdr.ipv4.dstAddr;
        hdr.influx.ndk_tstamp_h = meta.ingress_tstamp_system_h;
        hdr.influx.ndk_tstamp_l = meta.ingress_tstamp_system_l;
        hdr.influx.delay_h = meta.ingress_tstamp_system_h;
        hdr.influx.delay_l = meta.ingress_tstamp_system_l;
        hdr.influx.hop_meta_len = hdr.int_header.hop_metadata_len;
        hdr.influx.meta_len = hdr.int_shim.len - 3;

        hdr.ethernet.etherType = 0xffff;
        hdr.ipv4.setInvalid();
        hdr.int_shim.setInvalid();
        hdr.int_header.setInvalid();
    }

    action remove_tcp() {
        hdr.influx.setValid();
        hdr.influx.seq = hdr.tcp.seqNum;
        hdr.influx.ingress_port_id = hdr.tcp.srcPort;
        hdr.influx.egress_port_id = hdr.tcp.dstPort;
        hdr.tcp.setInvalid();
    }

    action remove_udp() {
        hdr.influx.setValid();
        hdr.influx.seq = 0;
        hdr.influx.ingress_port_id = hdr.udp.srcPort;
        hdr.influx.egress_port_id = hdr.udp.dstPort;
        hdr.udp.setInvalid();
    }

    action drop() {
        mark_to_drop(standard_metadata);
    }

    apply {
        if (SINK_ENABLE) {
            if (hdr.tcp.isValid())
                remove_tcp();
            else if (hdr.udp.isValid())
                remove_udp();
            else
                drop();

            fill_influx();
        }
    }
}

