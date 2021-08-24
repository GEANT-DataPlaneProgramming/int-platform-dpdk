# INT implementation
## Checksum
* The checksums work, but they are implemented quite unorthodoxly. Many auxiliary variables were used to achieve this. 

## Cloning
* Cloning packets is not possible. Setting clone metadata doesn't seem to do anything. Maybe something needs to be done through control plane which has limited options.
* Because cloning is not possible, what to do with the packet at sink node is determined by `table_sink_config` table. In default report packet is send.

## Instruction mask
Each part of mask needs to be 8b width unlike original implementation where it is only 4b width. This is caused by limitations mentioned in [General section](#general-1).
The main reason is that based on the mask value we have to determine which metadata to add in the transit part and because we can only use exact match.

## Other
* Port forwarding isn't supported. Mac address change is used instead.
* Register for seq number is missing because it doesn't work properly.
* Most tables have default action set rather then constant table entries.
* For source configuration table we use exact match, because other then this does not work, also we only match ip addresses because we cannot use two different headers in tables.
* We cannot use truncate to cut payload (for report packet), because compiler doesn't know this function.
* You can also manage entries thought control plane. Use telnet 0.0.0.0 8086 in default (it can be changed at start of the application).
* In layer 4 parsing decision whether proceed to next state (int_shim) or simply accept packet depends only on value of the dscp because we cannot use multiple select parameters.
* Because of bit width restriction described in [General section](#general-1), some fields had to be merged (headers with "fixed" size). Others were just aligned to value divisible by 8.
* This is also the reason, why there are same constants only with different bit width in header file.
* Whether to run sink,source or just transit is decided based on a constants that can be set during translation. Theoretically, all three nodes can be started at the same time.

# General
## Checksum
* In checksum can only be header fields. Simple values or metadata cannot be used.
If you add 8b field to checksum it is aligned to 16b. For example bit<8> 01 will be represented as bit<16> 0100.

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
* You can multiply only by values 2^N, others won't compile -> multiplying is realized through shift.
Same applies to division.

## Parser
* P4c does not allow multiple conditions in transition select (transition (condition1, condition2)). Since 14.7.2021 this should be supported (Based on pull requests in repository).
* Masking in parser cannot be used (&&& operand).

## Register
* Compiler cannot generate read. But even if we add it manually (by adding instruction to spec file), it doesn't seem to do anything.

## General
* Does not support casting. 
* All header fields must be divisible by 8, therefor the smallest possible width is 8b.
* Egress pipeline cannot be used, because for some reason no action (used in tables) is generated. For same reason extern controls cannot be used.
* Emitting empty/invalid headers may cause problems (Segmentation fault, Missing headers (other then empty)), but in most cases does nothing like it should.
This can be main problem with head stack because if all fields aren't valid, nothing will be emitted.