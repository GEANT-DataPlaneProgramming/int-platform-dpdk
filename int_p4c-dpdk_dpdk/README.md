## This repository is work in progress


### If you want to try this code anyway:


1. Download and install dpdk
    * You can do so using `dpdk-install.sh` script
2. Download and install p4c compiler
    * You should follow the instructions on [this site](https://github.com/p4lang/p4c) 

3. You should be able to compile and run p4 codes
    * To do so you can either run script `swx_p4c.sh` (before doing so please read [this](#compile-using-script) first)
    * To do so on your on follow [this](#compile-on-your-own)


### Compile using script
The script is very simple and therefore before it can be used it needs some care.
1. You need to change some paths
    * Specifically the one stored in `P4C` and `PIPE` variables
    In `P4C` variable path to the p4c-dpdk compiler should be stored
    In `PIPE` variable is path to the dpdk pipeline example provided by dpdk
    Originaly both variables have assigned values but it may not work due differentl folder layout. These default values may therefore work as an example 
    

### Compile on your own
1. Compile p4 program
    * Go to the p4c/build folder and compile. Example for source `./p4c-dpdk source.p4 -o source.spec`
2. Run p4 program
    * Go to the dpdk/examples/pipeline/build/pipeline folder.
    Program can be run using following command: `sudo ./pipeline --vdev=net_tap3,iface=int_in --vdev=net_tap2,iface=int_out -- -s source-cli`
    
### Notes
1. Virual interfaces
    * When aplication is running you should see two new interfaces (in default `int_in` and `int_out`). But in some cases only one interface is visible 
    (it should be the second one -> `int_out`). In this case you should add one more virual interface `IFC0` Here is an example `IFC0="--vdev=net_tap,iface=int_zero"` 
    `PARAM="$IFC0 $IFC1 $IFC2"`
    
2. Folder layout
    * Unfortunely all source files including .spec and -cli files needs to be in same folder. There is some problem with -cli script. Hopefuly this will be resolved soon. 
