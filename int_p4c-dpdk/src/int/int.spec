


struct ethernet_t {
	bit<48> dstAddr
	bit<48> srcAddr
	bit<16> etherType
}

struct ipv4_t {
	bit<8> version_ihl
	bit<8> dscp
	bit<16> totalLen
	bit<16> id
	bit<16> flags_flagOffset
	bit<8> ttl
	bit<8> protocol
	bit<16> hdrChecksum
	bit<32> srcAddr
	bit<32> dstAddr
}

struct udp_t {
	bit<16> srcPort
	bit<16> dstPort
	bit<16> len
	bit<16> csum
}

struct int_report_fixed_header_t {
	bit<8> ver
	bit<8> len
	bit<8> nprot
	bit<8> rep_md_bits
	bit<8> reserved
	bit<8> d
	bit<8> q
	bit<8> f
	bit<8> hw_id
	bit<8> padding
	bit<32> switch_id
	bit<32> seq_num
	bit<64> ingress_tstamp
}

struct tcp_t {
	bit<16> srcPort
	bit<16> dstPort
	bit<32> seqNum
	bit<32> ackNum
	bit<16> dataOffset_reserved_flags
	bit<16> winSize
	bit<16> csum
	bit<16> urgPoint
}

struct intl4_shim_t {
	bit<8> int_type
	bit<8> rsvd1
	bit<8> len
	bit<8> dscp
	bit<8> rsvd3
	bit<8> padding
}

struct int_header_t {
	bit<8> ver
	bit<8> rep
	bit<8> c
	bit<8> e
	bit<8> m
	bit<8> rsvd1
	bit<16> rsvd2
	bit<8> hop_metadata_len
	bit<8> remaining_hop_cnt
	bit<8> instruction_mask1
	bit<8> instruction_mask2
	bit<16> rsvd3
}

struct transit_int_header_t {
	bit<8> ver
	bit<8> rep
	bit<16> c_e
	bit<16> m_rsvd1
	bit<16> rsvd2
	bit<16> hop_info
	bit<16> instruction_mask
	bit<16> rsvd3
}

struct int_switch_id_t {
	bit<32> switch_id
}

struct int_port_ids_t {
	bit<32> ingress_port_id
	bit<32> egress_port_id
}

struct int_hop_latency_t {
	bit<32> hop_latency
}

struct int_q_occupancy_t {
	bit<8> q_id
	bit<24> q_occupancy
}

struct int_ingress_tstamp_t {
	bit<64> ingress_tstamp
}

struct int_egress_tstamp_t {
	bit<64> egress_tstamp
}

struct int_level2_port_ids_t {
	bit<16> ingress_port_id
	bit<16> egress_port_id
}

struct int_egress_port_tx_util_t {
	bit<32> egress_port_tx_util
}

struct influx_t {
	bit<32> srcAddr
	bit<32> dstAddr
	bit<16> ingress_port_id
	bit<16> egress_port_id
	bit<8> meta_len
	bit<8> hop_meta_len
	bit<16> rsvd1
	bit<64> ndk_timestamp
	bit<64> delay
	bit<32> seq
}

struct ck_helper_t {
	bit<16> old_udp_len
	bit<8> old_shim_len
	bit<16> old_hop
	bit<16> old_dscp
	bit<16> old_totalLen
	bit<16> ipv4_dscp
	bit<16> ipv4_protocol
}

struct cksum_state_t {
	bit<16> state_0
}

struct node_meta_t {
	bit<32> switch_id
	bit<16> ingress_port_id
	bit<16> egress_port_id
	bit<64> ingress_tstamp
	bit<64> egress_tstamp
}

struct metadata_t {
	bit<32> psa_ingress_parser_input_metadata_ingress_port
	bit<32> psa_ingress_parser_input_metadata_packet_path
	bit<32> psa_egress_parser_input_metadata_egress_port
	bit<32> psa_egress_parser_input_metadata_packet_path
	bit<32> psa_ingress_input_metadata_ingress_port
	bit<32> psa_ingress_input_metadata_packet_path
	bit<64> psa_ingress_input_metadata_ingress_timestamp
	bit<8> psa_ingress_input_metadata_parser_error
	bit<8> psa_ingress_output_metadata_class_of_service
	bit<8> psa_ingress_output_metadata_clone
	bit<16> psa_ingress_output_metadata_clone_session_id
	bit<8> psa_ingress_output_metadata_drop
	bit<8> psa_ingress_output_metadata_resubmit
	bit<32> psa_ingress_output_metadata_multicast_group
	bit<32> psa_ingress_output_metadata_egress_port
	bit<8> psa_egress_input_metadata_class_of_service
	bit<32> psa_egress_input_metadata_egress_port
	bit<32> psa_egress_input_metadata_packet_path
	bit<16> psa_egress_input_metadata_instance
	bit<64> psa_egress_input_metadata_egress_timestamp
	bit<8> psa_egress_input_metadata_parser_error
	bit<32> psa_egress_deparser_input_metadata_egress_port
	bit<8> psa_egress_output_metadata_clone
	bit<16> psa_egress_output_metadata_clone_session_id
	bit<8> psa_egress_output_metadata_drop
	bit<8> local_metadata_source
	bit<8> local_metadata_sink
	bit<8> local_metadata_remove_int
	bit<32> local_metadata_switch_id
	bit<16> local_metadata_insert_byte_cnt
	bit<8> local_metadata_int_hdr_word_len
	bit<8> local_metadata_sink_reporting_port
	bit<64> local_metadata_ingress_tstamp
	bit<32> local_metadata_ingress_port
	bit<8> local_metadata_dscp
	bit<8> local_metadata_hops
	bit<16> local_metadata_hops_16
	bit<16> local_metadata_total_hops_len
	bit<8> local_metadata_remove
	bit<16> local_metadata_l4_src
	bit<16> local_metadata_l4_dst
	bit<16> local_metadata_mask
	bit<16> Ingress_tmp_1
	bit<16> Ingress_tmp_2
	bit<16> Ingress_tmp_3
	bit<32> Ingress_tmp
	bit<32> Ingress_tmp_0
	bit<32> Ingress_seq_num_value_0
}
metadata instanceof metadata_t

header report_ethernet instanceof ethernet_t
header report_ipv4 instanceof ipv4_t
header report_udp instanceof udp_t
header report_fixed_header instanceof int_report_fixed_header_t
header ethernet instanceof ethernet_t
header ipv4 instanceof ipv4_t
header tcp instanceof tcp_t
header udp instanceof udp_t
header int_shim instanceof intl4_shim_t
header int_header instanceof int_header_t
header transit_int_header instanceof transit_int_header_t
header int_switch_id instanceof int_switch_id_t
header int_port_ids instanceof int_port_ids_t
header int_hop_latency instanceof int_hop_latency_t
header int_q_occupancy instanceof int_q_occupancy_t
header int_ingress_tstamp instanceof int_ingress_tstamp_t
header int_egress_tstamp instanceof int_egress_tstamp_t
header int_level2_port_ids instanceof int_level2_port_ids_t
header int_egress_port_tx_util instanceof int_egress_port_tx_util_t
header influx instanceof influx_t
header node_stack_0 instanceof node_meta_t
header node_stack_1 instanceof node_meta_t
header node_stack_2 instanceof node_meta_t
header node_stack_3 instanceof node_meta_t

header ck_helper instanceof ck_helper_t
header cksum_state instanceof cksum_state_t

struct configure_transit_arg_t {
	bit<32> switch_id
	bit<16> l3_mtu
}

struct send_arg_t {
	bit<32> port
}

struct send_report_arg_t {
	bit<48> dp_mac
	bit<32> dp_ip
	bit<48> collector_mac
	bit<32> collector_ip
	bit<16> collector_port
}

struct send_to_cpu_arg_t {
	bit<32> port
}

struct send_to_port_custom_arg_t {
	bit<32> port
}

struct psa_ingress_output_metadata_t {
	bit<8> class_of_service
	bit<8> clone
	bit<16> clone_session_id
	bit<8> drop
	bit<8> resubmit
	bit<32> multicast_group
	bit<32> egress_port
}

struct psa_egress_output_metadata_t {
	bit<8> clone
	bit<16> clone_session_id
	bit<8> drop
}

struct psa_egress_deparser_input_metadata_t {
	bit<32> egress_port
}

regarray report_seq_num_register_0 size 0x1 initval 0

action NoAction args none {
	return
}

action configure_transit args instanceof configure_transit_arg_t {
	mov m.local_metadata_switch_id t.switch_id
	mov m.local_metadata_insert_byte_cnt 0x0
	mov m.local_metadata_int_hdr_word_len 0x0
	return
}

action default_transit_conf args none {
	mov m.local_metadata_switch_id 0x9
	mov m.local_metadata_insert_byte_cnt 0x0
	mov m.local_metadata_int_hdr_word_len 0x0
	return
}

action int_set_header_0003_i0 args none {
	return
}

action int_set_header_0003_i1 args none {
	validate h.int_q_occupancy
	mov h.int_q_occupancy.q_id 0x0
	mov h.int_q_occupancy.q_occupancy 0x0
	add m.local_metadata_int_hdr_word_len 0x1
	add m.local_metadata_insert_byte_cnt 0x4
	return
}

action int_set_header_0003_i2 args none {
	validate h.int_hop_latency
	mov h.int_hop_latency.hop_latency 0x0
	add m.local_metadata_int_hdr_word_len 0x1
	add m.local_metadata_insert_byte_cnt 0x4
	return
}

action int_set_header_0003_i3 args none {
	validate h.int_egress_tstamp
	mov h.int_egress_tstamp.egress_tstamp 0x0
	validate h.int_hop_latency
	mov h.int_hop_latency.hop_latency 0x0
	add m.local_metadata_int_hdr_word_len 0x3
	add m.local_metadata_insert_byte_cnt 0xc
	return
}

action int_set_header_0003_i4 args none {
	validate h.int_port_ids
	mov h.int_port_ids.ingress_port_id m.local_metadata_ingress_port
	mov h.int_port_ids.egress_port_id m.psa_ingress_output_metadata_egress_port
	add m.local_metadata_int_hdr_word_len 0x1
	add m.local_metadata_insert_byte_cnt 0x4
	return
}

action int_set_header_0003_i5 args none {
	validate h.int_q_occupancy
	mov h.int_q_occupancy.q_id 0x0
	mov h.int_q_occupancy.q_occupancy 0x0
	validate h.int_port_ids
	mov h.int_port_ids.ingress_port_id m.local_metadata_ingress_port
	mov h.int_port_ids.egress_port_id m.psa_ingress_output_metadata_egress_port
	add m.local_metadata_int_hdr_word_len 0x2
	add m.local_metadata_insert_byte_cnt 0x8
	return
}

action int_set_header_0003_i6 args none {
	validate h.int_hop_latency
	mov h.int_hop_latency.hop_latency 0x0
	validate h.int_port_ids
	mov h.int_port_ids.ingress_port_id m.local_metadata_ingress_port
	mov h.int_port_ids.egress_port_id m.psa_ingress_output_metadata_egress_port
	add m.local_metadata_int_hdr_word_len 0x2
	add m.local_metadata_insert_byte_cnt 0x8
	return
}

action int_set_header_0003_i7 args none {
	validate h.int_q_occupancy
	mov h.int_q_occupancy.q_id 0x0
	mov h.int_q_occupancy.q_occupancy 0x0
	validate h.int_hop_latency
	mov h.int_hop_latency.hop_latency 0x0
	validate h.int_port_ids
	mov h.int_port_ids.ingress_port_id m.local_metadata_ingress_port
	mov h.int_port_ids.egress_port_id m.psa_ingress_output_metadata_egress_port
	add m.local_metadata_int_hdr_word_len 0x3
	add m.local_metadata_insert_byte_cnt 0xc
	return
}

action int_set_header_0003_i8 args none {
	validate h.int_switch_id
	mov h.int_switch_id.switch_id m.local_metadata_switch_id
	add m.local_metadata_int_hdr_word_len 0x1
	add m.local_metadata_insert_byte_cnt 0x4
	return
}

action int_set_header_0003_i9 args none {
	validate h.int_q_occupancy
	mov h.int_q_occupancy.q_id 0x0
	mov h.int_q_occupancy.q_occupancy 0x0
	validate h.int_switch_id
	mov h.int_switch_id.switch_id m.local_metadata_switch_id
	add m.local_metadata_int_hdr_word_len 0x2
	add m.local_metadata_insert_byte_cnt 0x8
	return
}

action int_set_header_0003_i10 args none {
	validate h.int_hop_latency
	mov h.int_hop_latency.hop_latency 0x0
	validate h.int_switch_id
	mov h.int_switch_id.switch_id m.local_metadata_switch_id
	add m.local_metadata_int_hdr_word_len 0x2
	add m.local_metadata_insert_byte_cnt 0x8
	return
}

action int_set_header_0003_i11 args none {
	validate h.int_q_occupancy
	mov h.int_q_occupancy.q_id 0x0
	mov h.int_q_occupancy.q_occupancy 0x0
	validate h.int_hop_latency
	mov h.int_hop_latency.hop_latency 0x0
	validate h.int_switch_id
	mov h.int_switch_id.switch_id m.local_metadata_switch_id
	add m.local_metadata_int_hdr_word_len 0x3
	add m.local_metadata_insert_byte_cnt 0xc
	return
}

action int_set_header_0003_i12 args none {
	validate h.int_port_ids
	mov h.int_port_ids.ingress_port_id m.local_metadata_ingress_port
	mov h.int_port_ids.egress_port_id m.psa_ingress_output_metadata_egress_port
	validate h.int_switch_id
	mov h.int_switch_id.switch_id m.local_metadata_switch_id
	add m.local_metadata_int_hdr_word_len 0x2
	add m.local_metadata_insert_byte_cnt 0x8
	return
}

action int_set_header_0003_i13 args none {
	validate h.int_q_occupancy
	mov h.int_q_occupancy.q_id 0x0
	mov h.int_q_occupancy.q_occupancy 0x0
	validate h.int_port_ids
	mov h.int_port_ids.ingress_port_id m.local_metadata_ingress_port
	mov h.int_port_ids.egress_port_id m.psa_ingress_output_metadata_egress_port
	validate h.int_switch_id
	mov h.int_switch_id.switch_id m.local_metadata_switch_id
	add m.local_metadata_int_hdr_word_len 0x3
	add m.local_metadata_insert_byte_cnt 0xc
	return
}

action int_set_header_0003_i14 args none {
	validate h.int_hop_latency
	mov h.int_hop_latency.hop_latency 0x0
	validate h.int_port_ids
	mov h.int_port_ids.ingress_port_id m.local_metadata_ingress_port
	mov h.int_port_ids.egress_port_id m.psa_ingress_output_metadata_egress_port
	validate h.int_switch_id
	mov h.int_switch_id.switch_id m.local_metadata_switch_id
	add m.local_metadata_int_hdr_word_len 0x3
	add m.local_metadata_insert_byte_cnt 0xc
	return
}

action int_set_header_0003_i15 args none {
	validate h.int_q_occupancy
	mov h.int_q_occupancy.q_id 0x0
	mov h.int_q_occupancy.q_occupancy 0x0
	validate h.int_hop_latency
	mov h.int_hop_latency.hop_latency 0x0
	validate h.int_port_ids
	mov h.int_port_ids.ingress_port_id m.local_metadata_ingress_port
	mov h.int_port_ids.egress_port_id m.psa_ingress_output_metadata_egress_port
	validate h.int_switch_id
	mov h.int_switch_id.switch_id m.local_metadata_switch_id
	add m.local_metadata_int_hdr_word_len 0x4
	add m.local_metadata_insert_byte_cnt 0x10
	return
}

action int_set_header_0407_i0 args none {
	return
}

action int_set_header_0407_i1 args none {
	validate h.int_egress_port_tx_util
	mov h.int_egress_port_tx_util.egress_port_tx_util 0x0
	add m.local_metadata_int_hdr_word_len 0x1
	add m.local_metadata_insert_byte_cnt 0x4
	return
}

action int_set_header_0407_i2 args none {
	validate h.int_level2_port_ids
	mov h.int_level2_port_ids.ingress_port_id 0x0
	mov h.int_level2_port_ids.egress_port_id 0x0
	add m.local_metadata_int_hdr_word_len 0x1
	add m.local_metadata_insert_byte_cnt 0x4
	return
}

action int_set_header_0407_i3 args none {
	validate h.int_egress_port_tx_util
	mov h.int_egress_port_tx_util.egress_port_tx_util 0x0
	validate h.int_level2_port_ids
	mov h.int_level2_port_ids.ingress_port_id 0x0
	mov h.int_level2_port_ids.egress_port_id 0x0
	add m.local_metadata_int_hdr_word_len 0x2
	add m.local_metadata_insert_byte_cnt 0x8
	return
}

action int_set_header_0407_i4 args none {
	validate h.int_egress_tstamp
	mov h.int_egress_tstamp.egress_tstamp 0x0
	add m.local_metadata_int_hdr_word_len 0x2
	add m.local_metadata_insert_byte_cnt 0x8
	return
}

action int_set_header_0407_i5 args none {
	validate h.int_egress_port_tx_util
	mov h.int_egress_port_tx_util.egress_port_tx_util 0x0
	validate h.int_egress_tstamp
	mov h.int_egress_tstamp.egress_tstamp 0x0
	add m.local_metadata_int_hdr_word_len 0x3
	add m.local_metadata_insert_byte_cnt 0xc
	return
}

action int_set_header_0407_i6 args none {
	validate h.int_level2_port_ids
	mov h.int_level2_port_ids.ingress_port_id 0x0
	mov h.int_level2_port_ids.egress_port_id 0x0
	validate h.int_egress_tstamp
	mov h.int_egress_tstamp.egress_tstamp 0x0
	add m.local_metadata_int_hdr_word_len 0x3
	add m.local_metadata_insert_byte_cnt 0xc
	return
}

action int_set_header_0407_i7 args none {
	validate h.int_egress_port_tx_util
	mov h.int_egress_port_tx_util.egress_port_tx_util 0x0
	validate h.int_level2_port_ids
	mov h.int_level2_port_ids.ingress_port_id 0x0
	mov h.int_level2_port_ids.egress_port_id 0x0
	validate h.int_egress_tstamp
	mov h.int_egress_tstamp.egress_tstamp 0x0
	add m.local_metadata_int_hdr_word_len 0x4
	add m.local_metadata_insert_byte_cnt 0x10
	return
}

action int_set_header_0407_i8 args none {
	validate h.int_ingress_tstamp
	mov h.int_ingress_tstamp.ingress_tstamp m.local_metadata_ingress_tstamp
	add m.local_metadata_int_hdr_word_len 0x2
	add m.local_metadata_insert_byte_cnt 0x8
	return
}

action int_set_header_0407_i9 args none {
	validate h.int_egress_port_tx_util
	mov h.int_egress_port_tx_util.egress_port_tx_util 0x0
	validate h.int_ingress_tstamp
	mov h.int_ingress_tstamp.ingress_tstamp m.local_metadata_ingress_tstamp
	add m.local_metadata_int_hdr_word_len 0x3
	add m.local_metadata_insert_byte_cnt 0xc
	return
}

action int_set_header_0407_i10 args none {
	validate h.int_level2_port_ids
	mov h.int_level2_port_ids.ingress_port_id 0x0
	mov h.int_level2_port_ids.egress_port_id 0x0
	validate h.int_ingress_tstamp
	mov h.int_ingress_tstamp.ingress_tstamp m.local_metadata_ingress_tstamp
	add m.local_metadata_int_hdr_word_len 0x3
	add m.local_metadata_insert_byte_cnt 0xc
	return
}

action int_set_header_0407_i11 args none {
	validate h.int_egress_port_tx_util
	mov h.int_egress_port_tx_util.egress_port_tx_util 0x0
	validate h.int_level2_port_ids
	mov h.int_level2_port_ids.ingress_port_id 0x0
	mov h.int_level2_port_ids.egress_port_id 0x0
	validate h.int_ingress_tstamp
	mov h.int_ingress_tstamp.ingress_tstamp m.local_metadata_ingress_tstamp
	add m.local_metadata_int_hdr_word_len 0x4
	add m.local_metadata_insert_byte_cnt 0x10
	return
}

action int_set_header_0407_i12 args none {
	validate h.int_egress_tstamp
	mov h.int_egress_tstamp.egress_tstamp 0x0
	validate h.int_ingress_tstamp
	mov h.int_ingress_tstamp.ingress_tstamp m.local_metadata_ingress_tstamp
	add m.local_metadata_int_hdr_word_len 0x4
	add m.local_metadata_insert_byte_cnt 0x10
	return
}

action int_set_header_0407_i13 args none {
	validate h.int_egress_port_tx_util
	mov h.int_egress_port_tx_util.egress_port_tx_util 0x0
	validate h.int_egress_tstamp
	mov h.int_egress_tstamp.egress_tstamp 0x0
	validate h.int_ingress_tstamp
	mov h.int_ingress_tstamp.ingress_tstamp m.local_metadata_ingress_tstamp
	add m.local_metadata_int_hdr_word_len 0x5
	add m.local_metadata_insert_byte_cnt 0x14
	return
}

action int_set_header_0407_i14 args none {
	validate h.int_level2_port_ids
	mov h.int_level2_port_ids.ingress_port_id 0x0
	mov h.int_level2_port_ids.egress_port_id 0x0
	validate h.int_egress_tstamp
	mov h.int_egress_tstamp.egress_tstamp 0x0
	validate h.int_ingress_tstamp
	mov h.int_ingress_tstamp.ingress_tstamp m.local_metadata_ingress_tstamp
	add m.local_metadata_int_hdr_word_len 0x5
	add m.local_metadata_insert_byte_cnt 0x14
	return
}

action int_set_header_0407_i15 args none {
	validate h.int_egress_port_tx_util
	mov h.int_egress_port_tx_util.egress_port_tx_util 0x0
	validate h.int_level2_port_ids
	mov h.int_level2_port_ids.ingress_port_id 0x0
	mov h.int_level2_port_ids.egress_port_id 0x0
	validate h.int_egress_tstamp
	mov h.int_egress_tstamp.egress_tstamp 0x0
	validate h.int_ingress_tstamp
	mov h.int_ingress_tstamp.ingress_tstamp m.local_metadata_ingress_tstamp
	add m.local_metadata_int_hdr_word_len 0x6
	add m.local_metadata_insert_byte_cnt 0x18
	return
}

action send_report args instanceof send_report_arg_t {
	validate h.report_ethernet
	mov h.report_ethernet.dstAddr t.collector_mac
	mov h.report_ethernet.srcAddr t.dp_mac
	mov h.report_ethernet.etherType 0x800
	validate h.report_ipv4
	mov h.report_ipv4.version_ihl 0x45
	mov h.report_ipv4.dscp 0x0
	mov h.report_ipv4.totalLen h.ipv4.totalLen
	add h.report_ipv4.totalLen 0x40
	mov h.report_ipv4.id 0x0
	mov h.report_ipv4.flags_flagOffset 0x0
	mov h.report_ipv4.ttl 0x40
	mov h.report_ipv4.protocol 0x11
	mov h.report_ipv4.srcAddr t.dp_ip
	mov h.report_ipv4.dstAddr t.collector_ip
	validate h.report_udp
	mov h.report_udp.srcPort 0x0
	mov h.report_udp.dstPort t.collector_port
	mov m.Ingress_tmp_1 h.ipv4.totalLen
	add m.Ingress_tmp_1 0x40
	mov h.report_udp.len m.Ingress_tmp_1
	add h.report_udp.len 0xffec
	validate h.report_fixed_header
	mov h.report_fixed_header.ver 0x1
	mov h.report_fixed_header.len 0x4
	mov h.report_fixed_header.nprot 0x0
	mov h.report_fixed_header.rep_md_bits 0x0
	mov h.report_fixed_header.reserved 0x0
	mov h.report_fixed_header.d 0x0
	mov h.report_fixed_header.q 0x0
	mov h.report_fixed_header.f 0x1
	mov h.report_fixed_header.hw_id 0x0
	mov h.report_fixed_header.switch_id m.local_metadata_switch_id
	regrd m.Ingress_seq_num_value_0 report_seq_num_register_0 0x0
	mov h.report_fixed_header.seq_num m.Ingress_seq_num_value_0
	mov m.Ingress_tmp m.Ingress_seq_num_value_0
	add m.Ingress_tmp 0x1
	regwr report_seq_num_register_0 0x0 m.Ingress_tmp
	mov h.report_fixed_header.ingress_tstamp m.psa_ingress_input_metadata_ingress_timestamp
	return
}

action remove_int args none {
	mov m.local_metadata_remove 0x1
	validate h.ck_helper
	mov h.ck_helper.old_udp_len h.udp.len
	mov h.ck_helper.old_totalLen h.ipv4.totalLen
	mov h.ck_helper.old_dscp 0x20
	mov h.ck_helper.ipv4_dscp 0x0
	mov h.ipv4.dscp h.int_shim.dscp
	mov m.Ingress_tmp_2 h.ipv4.totalLen
	add m.Ingress_tmp_2 0xffec
	mov h.ipv4.totalLen m.Ingress_tmp_2
	sub h.ipv4.totalLen m.local_metadata_total_hops_len
	mov h.udp.len h.ipv4.totalLen
	add h.udp.len 0xffec
	invalidate h.int_switch_id
	invalidate h.int_port_ids
	invalidate h.int_ingress_tstamp
	invalidate h.int_egress_tstamp
	invalidate h.int_hop_latency
	invalidate h.int_level2_port_ids
	invalidate h.int_q_occupancy
	invalidate h.int_egress_port_tx_util
	invalidate h.int_shim
	invalidate h.transit_int_header
	return
}

action def_action args none {
	validate h.report_ethernet
	mov h.report_ethernet.dstAddr 0xbbbbbbbbbbbb
	mov h.report_ethernet.srcAddr 0xcccccccccccc
	mov h.report_ethernet.etherType 0x800
	validate h.report_ipv4
	mov h.report_ipv4.version_ihl 0x45
	mov h.report_ipv4.dscp 0x0
	mov h.report_ipv4.totalLen h.ipv4.totalLen
	add h.report_ipv4.totalLen 0x40
	mov h.report_ipv4.id 0x0
	mov h.report_ipv4.flags_flagOffset 0x0
	mov h.report_ipv4.ttl 0x40
	mov h.report_ipv4.protocol 0x11
	mov h.report_ipv4.srcAddr 0xc0aabbcc
	mov h.report_ipv4.dstAddr 0xc0aabbdd
	validate h.report_udp
	mov h.report_udp.srcPort 0x0
	mov h.report_udp.dstPort 0x4268
	mov m.Ingress_tmp_3 h.ipv4.totalLen
	add m.Ingress_tmp_3 0x40
	mov h.report_udp.len m.Ingress_tmp_3
	add h.report_udp.len 0xffec
	validate h.report_fixed_header
	mov h.report_fixed_header.ver 0x1
	mov h.report_fixed_header.len 0x4
	mov h.report_fixed_header.nprot 0x0
	mov h.report_fixed_header.rep_md_bits 0x0
	mov h.report_fixed_header.reserved 0x0
	mov h.report_fixed_header.d 0x0
	mov h.report_fixed_header.q 0x0
	mov h.report_fixed_header.f 0x1
	mov h.report_fixed_header.hw_id 0x0
	mov h.report_fixed_header.switch_id m.local_metadata_switch_id
	regrd m.Ingress_seq_num_value_0 report_seq_num_register_0 0x0
	mov h.report_fixed_header.seq_num m.Ingress_seq_num_value_0
	mov m.Ingress_tmp_0 m.Ingress_seq_num_value_0
	add m.Ingress_tmp_0 0x1
	regwr report_seq_num_register_0 0x0 m.Ingress_tmp_0
	mov h.report_fixed_header.ingress_tstamp m.psa_ingress_input_metadata_ingress_timestamp
	return
}

action send_to_cpu args instanceof send_to_cpu_arg_t {
	mov m.psa_ingress_output_metadata_egress_port t.port
	return
}

action send_to_port_custom args instanceof send_to_port_custom_arg_t {
	mov m.psa_ingress_output_metadata_egress_port t.port
	return
}

action send args instanceof send_arg_t {
	mov m.psa_ingress_output_metadata_egress_port t.port
	return
}

table tb_int_transit {
	actions {
		configure_transit
		default_transit_conf
	}
	default_action default_transit_conf args none 
	size 0x10000
}


table tb_int_inst_0003 {
	key {
		m.local_metadata_mask exact
	}
	actions {
		int_set_header_0003_i0
		int_set_header_0003_i1
		int_set_header_0003_i2
		int_set_header_0003_i3
		int_set_header_0003_i4
		int_set_header_0003_i5
		int_set_header_0003_i6
		int_set_header_0003_i7
		int_set_header_0003_i8
		int_set_header_0003_i9
		int_set_header_0003_i10
		int_set_header_0003_i11
		int_set_header_0003_i12
		int_set_header_0003_i13
		int_set_header_0003_i14
		int_set_header_0003_i15
		NoAction
	}
	default_action NoAction args none 
	size 0x10000
}


table tb_int_inst_0407 {
	key {
		m.local_metadata_mask exact
	}
	actions {
		int_set_header_0407_i0
		int_set_header_0407_i1
		int_set_header_0407_i2
		int_set_header_0407_i3
		int_set_header_0407_i4
		int_set_header_0407_i5
		int_set_header_0407_i6
		int_set_header_0407_i7
		int_set_header_0407_i8
		int_set_header_0407_i9
		int_set_header_0407_i10
		int_set_header_0407_i11
		int_set_header_0407_i12
		int_set_header_0407_i13
		int_set_header_0407_i14
		int_set_header_0407_i15
		NoAction
	}
	default_action NoAction args none 
	size 0x10000
}


table table_sink_config {
	key {
		h.udp.srcPort exact
	}
	actions {
		send_report
		remove_int
		def_action
	}
	default_action def_action args none 
	size 0x10000
}


table tb_forward {
	key {
		h.ethernet.dstAddr exact
	}
	actions {
		send_to_cpu
		send_to_port_custom
		NoAction
	}
	default_action NoAction args none 
	size 0x10000
}


table tb_port_forward {
	key {
		m.psa_ingress_output_metadata_egress_port exact
	}
	actions {
		send
		NoAction
	}
	default_action NoAction args none 
	size 0x10000
}


apply {
	rx m.psa_ingress_input_metadata_ingress_port
	mov m.psa_ingress_output_metadata_drop 0x0
	time m.psa_ingress_input_metadata_ingress_timestamp
	extract h.ethernet
	jmpeq MYINGRESSPARSER_PARSE_IPV4 h.ethernet.etherType 0x800
	jmp MYINGRESSPARSER_ACCEPT
	MYINGRESSPARSER_PARSE_IPV4 :	extract h.ipv4
	mov m.local_metadata_dscp h.ipv4.dscp
	jmpeq MYINGRESSPARSER_PARSE_UDP h.ipv4.protocol 0x11
	jmpeq MYINGRESSPARSER_PARSE_TCP h.ipv4.protocol 0x6
	jmp MYINGRESSPARSER_ACCEPT
	MYINGRESSPARSER_PARSE_UDP :	extract h.udp
	mov m.local_metadata_l4_src h.udp.srcPort
	mov m.local_metadata_l4_dst h.udp.dstPort
	and m.local_metadata_dscp 0x3f
	jmpeq MYINGRESSPARSER_PARSE_INT_SHIM m.local_metadata_dscp 0x20
	jmp MYINGRESSPARSER_ACCEPT
	MYINGRESSPARSER_PARSE_TCP :	extract h.tcp
	mov m.local_metadata_l4_src h.tcp.srcPort
	mov m.local_metadata_l4_dst h.tcp.dstPort
	and m.local_metadata_dscp 0x3f
	jmpeq MYINGRESSPARSER_PARSE_INT_SHIM m.local_metadata_dscp 0x20
	jmp MYINGRESSPARSER_ACCEPT
	MYINGRESSPARSER_PARSE_INT_SHIM :	extract h.int_shim
	extract h.transit_int_header
	MYINGRESSPARSER_ACCEPT :	jmpv LABEL_0TRUE h.udp
	jmpv LABEL_0TRUE h.tcp
	jmp LABEL_0END
	LABEL_0TRUE :	mov m.local_metadata_ingress_tstamp m.psa_ingress_input_metadata_ingress_timestamp
	mov m.local_metadata_ingress_port m.psa_ingress_input_metadata_ingress_port
	table tb_forward
	table tb_port_forward
	validate h.ck_helper
	mov h.ck_helper.old_udp_len h.udp.len
	mov h.ck_helper.old_shim_len h.int_shim.len
	mov h.ck_helper.old_hop h.transit_int_header.hop_info
	mov h.ck_helper.old_totalLen h.ipv4.totalLen
	jmpnv LABEL_1END h.transit_int_header
	jmpeq LABEL_2FALSE h.transit_int_header.hop_info 0x600
	add h.transit_int_header.hop_info 0xffff
	table tb_int_transit
	mov m.local_metadata_mask h.transit_int_header.instruction_mask
	and m.local_metadata_mask 0xf0
	table tb_int_inst_0003
	mov m.local_metadata_mask h.transit_int_header.instruction_mask
	and m.local_metadata_mask 0xf
	table tb_int_inst_0407
	add h.ipv4.totalLen m.local_metadata_insert_byte_cnt
	jmpnv LABEL_3END h.udp
	add h.udp.len m.local_metadata_insert_byte_cnt
	LABEL_3END :	jmpnv LABEL_1END h.int_shim
	add h.int_shim.len m.local_metadata_int_hdr_word_len
	jmp LABEL_1END
	jmp LABEL_1END
	LABEL_2FALSE :	jmpeq LABEL_5TRUE h.transit_int_header.c_e 0x0
	jmpeq LABEL_5TRUE h.transit_int_header.c_e 0x100
	jmp LABEL_1END
	LABEL_5TRUE :	add h.transit_int_header.c_e 0x1
	LABEL_1END :	jmpnv LABEL_0END h.transit_int_header
	mov m.local_metadata_remove 0x0
	table table_sink_config
	LABEL_0END :	jmpneq LABEL_DROP m.psa_ingress_output_metadata_drop 0x0
	mov h.cksum_state.state_0 0x0
	cksub h.cksum_state.state_0 h.ipv4.hdrChecksum
	cksub h.cksum_state.state_0 h.ck_helper.old_totalLen
	ckadd h.cksum_state.state_0 h.ipv4.totalLen
	mov h.ipv4.hdrChecksum h.cksum_state.state_0
	mov h.cksum_state.state_0 0x0
	cksub h.cksum_state.state_0 h.udp.csum
	cksub h.cksum_state.state_0 h.ck_helper.old_udp_len
	cksub h.cksum_state.state_0 h.ck_helper.old_udp_len
	cksub h.cksum_state.state_0 h.ck_helper.old_shim_len
	cksub h.cksum_state.state_0 h.ck_helper.old_hop
	ckadd h.cksum_state.state_0 h.udp.len
	ckadd h.cksum_state.state_0 h.udp.len
	ckadd h.cksum_state.state_0 h.int_shim.len
	ckadd h.cksum_state.state_0 h.transit_int_header.hop_info
	ckadd h.cksum_state.state_0 h.int_switch_id.switch_id
	ckadd h.cksum_state.state_0 h.int_port_ids.ingress_port_id
	ckadd h.cksum_state.state_0 h.int_port_ids.egress_port_id
	ckadd h.cksum_state.state_0 h.int_hop_latency.hop_latency
	ckadd h.cksum_state.state_0 h.int_q_occupancy.q_id
	ckadd h.cksum_state.state_0 h.int_q_occupancy.q_occupancy
	ckadd h.cksum_state.state_0 h.int_ingress_tstamp.ingress_tstamp
	ckadd h.cksum_state.state_0 h.int_egress_tstamp.egress_tstamp
	ckadd h.cksum_state.state_0 h.int_level2_port_ids.ingress_port_id
	ckadd h.cksum_state.state_0 h.int_level2_port_ids.egress_port_id
	ckadd h.cksum_state.state_0 h.int_egress_port_tx_util.egress_port_tx_util
	mov h.udp.csum h.cksum_state.state_0
	jmpnv LABEL_8END h.transit_int_header
	emit h.report_ethernet
	emit h.report_ipv4
	emit h.report_udp
	emit h.report_fixed_header
	LABEL_8END :	emit h.ethernet
	emit h.ipv4
	jmpnv LABEL_9END h.udp
	emit h.udp
	LABEL_9END :	jmpnv LABEL_10END h.tcp
	emit h.tcp
	LABEL_10END :	emit h.int_shim
	emit h.transit_int_header
	emit h.int_switch_id
	emit h.int_port_ids
	emit h.int_hop_latency
	emit h.int_q_occupancy
	emit h.int_ingress_tstamp
	emit h.int_egress_tstamp
	emit h.int_level2_port_ids
	emit h.int_egress_port_tx_util
	tx m.psa_ingress_output_metadata_egress_port
	LABEL_DROP : drop
}


