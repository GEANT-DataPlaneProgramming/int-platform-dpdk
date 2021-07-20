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

/////////////////////////////////////////////////////////////////////////////////////////////////////////


#include <core.p4>
#include <v1model.p4>

#include "config.p4"
#include "include/headers.p4"
#include "include/parser.p4"
#include "include/int_source.p4"
#include "include/int_transit.p4"

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t ig_intr_md) {
	apply {	
		if (!hdr.udp.isValid() && !hdr.tcp.isValid())
			exit;

        Int_source.apply(hdr, meta, ig_intr_md);
        Int_transit.apply(hdr, meta, ig_intr_md);
	}
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t eg_intr_md) {
    apply {
    }
}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
