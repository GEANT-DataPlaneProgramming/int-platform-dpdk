# This file comments on the solution implemented for p4c-dpdk compiler
* [INT summary info](#int-summary-info)
* [Differences in implementation compared to bmv2](#differences-in-implementation-compared-to-bmv2)
* [General information about restrictions in compiler and interpret](#general-information-about-restrictions-in-compiler-and-interpret)

# INT summary info
## General functionality
|Feature			| State |
|-------------------|------|
|Checksum			| OK  |
|Cloning			| Doesn't work.  |
|Seq numbers		| OK  |
|Port forwarding	| OK  |
|Truncate			| We cannot use truncate to cut payload (for report packet), because compiler doesn't know this function.  |
|Egress pipeline	| Cannot generate tables and actions therefore cannot be used.  |

## Metadata
|Feature			| State |
|-------------------|------|
|Switch id 			| OK  |
|Port id			| OK  |
|Level 2 port id	| Not present  |
|Ingress timestamp	| Software time is used.  |
|Egress timestamp	| Not available, egress pipeline cannot be used.  |
|Hop latency		| Due to missing egress timestamp cannot be calculated.  |
|Queue occupancy	| PSA architecture doesn't yet define any mechanisms to access information such as egress port link utilization or queue occupancy.  |
|Egress port tx util| PSA architecture doesn't yet define any mechanisms to access information such as egress port link utilization or queue occupancy.  |

# Differences in implementation compared to bmv2
## Checksum
Many auxiliary variables were used to achieve this.
## Tables
* Masking for selecting metadata set to add is done before applying the tables because only exact match can be used.  
* Constant table entries cannot been used. 
* For source configuration table we use exact match, because other then this does not work, also we only match ip addresses because we cannot use two different headers in tables.
## Cloning
* Because cloning is not possible, what to do with the packet at sink node is determined by `table_sink_config` table. (In default report packet is send.)

## Other
* Because of bit width restriction, some fields had to be merged (headers with "fixed" size). Others were just aligned to value divisible by 8. This is also the reason, why there are same constants only with different bit width in header file.
* While configuring source `hop_metadata_len` and `max_hop`, must be given as one number. Where upper 8b corresponds to HOP_META_LEN lower 8b to MAX_HOP
* Whether to run sink,source or just transit is decided based on a constants that can be set during translation. Note that if you try to run sink and source at the same time, it will end on seg fault.
* All tables which configures nodes have default action set. This can be changed using one of the command line argument in `generate.py` script.

# General information about restrictions in compiler and interpret
## Tables
* In table key cannot be used different header. For example this won't work
    <pre><code>table table_influx {
	    key {
	    	h.ipv4.srcAddr exact
	    	h.influx.egress_port_id exact
	    }</pre></code>
* As match method for key in tables, only exact can be used. Others cause interpret error.
* Constant entry for table cannot be used. 
* If you want to set default action with parameters for table. You need to create new action without parameters and in this action you should call your desired one.
* If some table is not used, compiler displays warning and in some cases the code may not work correctly.

## Compiler problems 
* If header stack is used (maybe in other cases to) p4c generates `verify 0 error.StackOutOfBounds` this will cause interpret error.
* Sometimes p4c compiler incorrectly generates subtraction.
* You can multiply only by values 2^N, others won't compile -> multiplying is realized through shift. Same applies to division.

## Parser
* P4c does not allow multiple conditions in transition select (transition (condition1, condition2)). Since 14.7.2021 this should be supported (Based on pull requests in repository).
* Masking in parser cannot be used (&&& operand).

## Other
* Does not support casting. 
* All header fields must be divisible by 8, therefor the smallest possible width is 8b.
* Egress pipeline cannot be used, because for some reason no action (used in tables) is generated. For same reason extern controls cannot be used.
* Emitting empty/invalid headers may cause problems (Segmentation fault, Missing headers (other then this empty emitted)), but in most cases does nothing like it should.
This can be main problem with head stack because if all fields aren't valid, nothing will be emitted.
* Compiler doesn't know truncate function
* In checksum can only be header fields. Simple values or metadata cannot be used. If you add 8b field to checksum it is aligned to 16b. For example bit<8> 01 will be represented as bit<16> 0100.