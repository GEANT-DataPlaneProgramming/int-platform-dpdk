# INT implementation for p4c-dpdk compiler
This implementation uses psa model

## Work in progress


### If you want to try this code anyway:


1. Download and install dpdk
    * You can do so using `dpdk-install.sh` script.
2. Download and install p4c compiler
    * Compiler is part of this repository as a submodule. You can find it in a p4c folder.
    * You should follow the instructions in [p4lang/p4c repository](https://github.com/p4lang/p4c) .
    * Or you can use `p4-install.sh` script available in `install` folder. (There is also script for installing dependencies).

3. You should be able to compile and run p4 codes
    * To do so you can either run script `swx_p4c.sh` (before doing so please read [Compile using script](#compile-using-script) section first).
    * To do so on your own follow [Compile on your own](#compile-on-your-own).


### Compile using script
The script is very simple and therefore before use it needs some care.
1. You need to change some paths
    * Specifically the one stored in `P4C` and `PIPE` variables.
    In `P4C` variable path to the p4c-dpdk compiler should be stored.
    In `PIPE` variable is path to the dpdk pipeline example provided by dpdk.
    Originally both variables have assigned values but it may not work due different folder layout. These default values may therefore work as an example.
    

### Compile on your own
1. Generate p4 code from template
    * Use python script in src/ folder to generate p4 files. You will need to generate header file along with main int file.
2. Compile p4 program
    * Go to the p4c/build folder and compile. Example `./p4c-dpdk int.p4 -o int.spec`.
3. Run p4 program
    * Go to the dpdk/examples/pipeline/build/pipeline folder.
    Program can be run using following command: `sudo ./pipeline --vdev=net_tap2,iface=int_out --vdev=net_tap3,iface=int_in -- -s int-cli`.
    Note: You don't need virtual interfaces if you binded your device to dpdk.

### Notes
1. Sink node
    This implementation does not support cloning therefore only one packet is produced. In default it is report packet. Note that key is present which match udp source ports, in default 42 should produce original packet and 800 report packet.
2. Running code
    All related files should be in same folder ex. all files for running source.p4 (source.spec, source-cli, source-tables) should be in one folder. This is because dpdk interpret has some problem when files are somewhere else.