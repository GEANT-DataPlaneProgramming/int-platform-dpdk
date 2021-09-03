
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
}
metadata instanceof metadata_t

header ethernet instanceof ethernet_t
header ipv4 instanceof ipv4_t

struct change_dst_ip_arg_t {
	bit<32> new_ip
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

action NoAction args none {
	return
}

action change_dst_ip args instanceof change_dst_ip_arg_t {
	mov h.ipv4.dstAddr t.new_ip
	return
}

table tb_port_forward {
	key {
		h.ipv4.dstAddr exact
	}
	actions {
		change_dst_ip
		NoAction
	}
	default_action NoAction args none 
	size 0x10000
}


apply {
	rx m.psa_ingress_input_metadata_ingress_port
	mov m.psa_ingress_output_metadata_drop 0x0
	extract h.ethernet
	jmpeq MYINGRESSPARSER_PARSE_IPV4 h.ethernet.etherType 0x800
	jmp MYINGRESSPARSER_ACCEPT
	MYINGRESSPARSER_PARSE_IPV4 :	extract h.ipv4
	MYINGRESSPARSER_ACCEPT :	table tb_port_forward
	jmpneq LABEL_DROP m.psa_ingress_output_metadata_drop 0x0
	emit h.ethernet
	emit h.ipv4
	extract h.ethernet
	jmpeq MYEGRESSPARSER_PARSE_IPV4 h.ethernet.etherType 0x800
	jmp MYEGRESSPARSER_ACCEPT
	MYEGRESSPARSER_PARSE_IPV4 :	extract h.ipv4
	MYEGRESSPARSER_ACCEPT :	emit h.ethernet
	emit h.ipv4
	tx m.psa_ingress_output_metadata_egress_port
	LABEL_DROP : drop
}


