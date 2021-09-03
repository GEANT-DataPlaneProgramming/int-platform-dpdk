
 
#include <core.p4>
#include <psa.p4>

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

struct metadata_t {
}

struct empty_metadata_t {
}

struct clone_i2e_metadata_t{
}

struct headers_t {
    ethernet_t                  ethernet;
    ipv4_t                      ipv4;
}

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
        transition accept;
    }
}

control MyIngress(
    inout   headers_t                       hdr,
    inout   metadata_t                      meta,
    in      psa_ingress_input_metadata_t    standard_metadata,
    inout   psa_ingress_output_metadata_t   ostd
    ) 
{
    // action change_dst_ip(bit<32> new_ip) {
    //     hdr.ipv4.dstAddr = new_ip;
    // }

    // table tb_port_forward {
    //     actions = {
    //         change_dst_ip;
    //     }
    //     key = {
    //         hdr.ipv4.dstAddr: exact;
    //     }
    // }

    apply {
       // tb_port_forward.apply();
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

    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
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
    )
{
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
        transition accept;
    }
}

control MyEgress(
    inout   headers_t                       hdr,
    inout   metadata_t                      meta,
    in      psa_egress_input_metadata_t     istd,
    inout   psa_egress_output_metadata_t    ostd
) 
{
   action change_dst_ip(bit<32> new_ip) {
        hdr.ipv4.dstAddr = new_ip;
    }

    table tb_port_forward {
        actions = {
            change_dst_ip;
        }
        key = {
            hdr.ipv4.dstAddr: exact;
        }
    }

    apply {
        tb_port_forward.apply();
    }
}

control MyEgressDeparser(
            packet_out                              packet, 
    out     empty_metadata_t                        clone_e2e_meta, 
    out     empty_metadata_t                        recirculate_meta, 
    inout   headers_t                               hdr, 
    in      metadata_t                              meta, 
    in      psa_egress_output_metadata_t            istd, 
    in      psa_egress_deparser_input_metadata_t    edstd
) 
{
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
    }
}

IngressPipeline(MyIngressParser(), MyIngress(), MyIngressDeparser()) ip;

EgressPipeline(MyEgressParser(), MyEgress(), MyEgressDeparser()) ep;

PSA_Switch(ip, PacketReplicationEngine(), ep, BufferingQueueingEngine()) main;