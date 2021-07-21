#include <core.p4>
#include <psa.p4>
#include "headers.p4"

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
            // 8w0x6: parse_tcp;
            default: accept;
        }
    }

    state parse_udp {
        packet.extract(hdr.udp);
        transition select(meta.dscp) {
            default: accept; 
        }
    }
}

control MyIngress(
    inout   headers_t                       hdr,
    inout   metadata_t                      meta,
    in      psa_ingress_input_metadata_t    standard_metadata,
    inout   psa_ingress_output_metadata_t   ostd
    ) 
{
    action configure_source(
        bit<16> hop_metadata_len_max_hop, 
        bit<16> ins_mask,
        bit<8> ins_mask1,
        bit<8> ins_mask2
        ) 
    {
        hdr.transit_int_header.setValid();
        hdr.ck_helper.setValid();
        hdr.int_shim.setValid();

        hdr.ck_helper.old_udp_len = hdr.udp.len;
        hdr.ck_helper.old_dscp = 0;
        hdr.ck_helper.old_totalLen = hdr.ipv4.totalLen;

        hdr.int_shim.int_type = INT_TYPE_HOP_BY_HOP;
        hdr.int_shim.len = 3;
        
        hdr.transit_int_header.ver = INT_VERSION;
        hdr.transit_int_header.rep = 0;
        hdr.transit_int_header.c_e = 0;
        hdr.transit_int_header.m_rsvd1 = MAX_HOP_16;
        hdr.transit_int_header.rsvd2 = 0;
        hdr.transit_int_header.rsvd3 = 0;

        hdr.transit_int_header.hop_info = hop_metadata_len_max_hop;

        hdr.transit_int_header.instruction_mask1 = ins_mask1;
        hdr.transit_int_header.instruction_mask2 = ins_mask2;
        hdr.ck_helper.instruction_mask = ins_mask;
        
        hdr.int_shim.dscp = hdr.ipv4.dscp;
        hdr.ipv4.dscp = IPv4_DSCP_INT;
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + INT_ALL_HEADER_LEN_BYTES;  // adding size of INT headers
        
        hdr.udp.len = hdr.udp.len + INT_ALL_HEADER_LEN_BYTES;

        hdr.ck_helper.ipv4_protocol = 0x11;
        hdr.ck_helper.ipv4_dscp = IPv4_DSCP_INT_16;
    }

    action default_conf()
    {
        configure_source(HOP_INFO, INSTRUCTION_MASK_COMPLET, INSTRUCTION_MASK1, INSTRUCTION_MASK2);
    }

    // INT source must be configured per each flow which must be monitored using INT
    // Flow is defined by src IP, dst IP, src TCP/UDP port, dst TCP/UDP port 
    // When INT source configured for a flow then a node adds INT shim header and first INT node metadata headers
    table tb_int_source {
        actions = {
            configure_source;
            default_conf;
        }
        key = {
            
        }
        size = 127;
        default_action = default_conf();
    }

    action activate_source() {
        meta.source = 8w1;
    }

    action do_nothing() {
        meta.source = 8w0;
    }
    
    // table used to active INT source for a ingress port of the switch
    table tb_activate_source {
        key = {
            hdr.ipv4.dscp: exact;
        }
        actions = {
            activate_source;
            do_nothing;
        }
        default_action = activate_source();
        size = 255;
    }

    apply {
        // in case of frame clone for the INT sink reporting
        // ingress timestamp is not available on Egress pipeline
        meta.ingress_tstamp = 0x0;
        meta.ingress_port = 0x0;
        
        //check if packet appeard on ingress port with active INT source
        tb_activate_source.apply();
        
        if (meta.source == 8w1)      //1w1
            //apply INT source logic on INT monitored flow
            tb_int_source.apply();
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
        ck.clear();

        ck.subtract(hdr.udp.csum);
        ck.subtract(hdr.ck_helper.old_udp_len);
        ck.subtract(hdr.ck_helper.old_udp_len);
        hdr.transit_int_header.rsvd3 = ck.get();

        ck.add({
            hdr.udp.len,
            hdr.udp.len,

            hdr.int_shim.int_type,
            hdr.int_shim.rsvd1,
            hdr.int_shim.len,
            hdr.int_shim.dscp,
            hdr.int_shim.rsvd3,

            hdr.transit_int_header.ver,
            hdr.transit_int_header.rep,
            hdr.transit_int_header.c_e,
            hdr.transit_int_header.m_rsvd1,
            hdr.transit_int_header.rsvd2,
            hdr.transit_int_header.hop_info,
            hdr.ck_helper.instruction_mask,
            hdr.transit_int_header.rsvd3
        });
        hdr.udp.csum = ck.get();
        
        // original headers
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.udp);

        // INT headers
        packet.emit(hdr.int_shim);
        packet.emit(hdr.transit_int_header);
    }
}

parser MyEgressParser(
            packet_in                           buffer, 
    out     headers_t                           hdr, 
    inout   metadata_t                          meta, 
    in      psa_egress_parser_input_metadata_t  istd, 
    in      empty_metadata_t                    normal_meta, 
    in      clone_i2e_metadata_t                     clone_i2e_meta, 
    in      empty_metadata_t                    clone_e2e_meta
    )
{
    state start {
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
    apply {  }
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
    }
}

IngressPipeline(MyIngressParser(), MyIngress(), MyIngressDeparser()) ip;

EgressPipeline(MyEgressParser(), MyEgress(), MyEgressDeparser()) ep;

PSA_Switch(ip, PacketReplicationEngine(), ep, BufferingQueueingEngine()) main;