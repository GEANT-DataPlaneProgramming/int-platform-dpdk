P4 implementation of INT for DPDK 
=========

This implementation uses the [t4p4s](https://github.com/MarioKuka/t4p4s) compiler that can compile a P4 program into a DPDK application.
All source code and scripts are located in `./int_dpdk` directory.

INT P4 program
--------
P4 source code is located in `./int_dpdk/p4src/int_v1.0`. At this point, program implements very limited functionality of the Source and Transit INT nodes. The Sink node is not yet supported. Functionality of Source node can be enabled or disabled before compilation by define in `./int_dpdk/p4src/int_v1.0/config.p4`.

[t4p4s](https://github.com/MarioKuka/t4p4s) compiler has many bugs and unsupported features that need to be fixed/implemented to support a full INT implementation from [in_band_telemetry_bvm2](https://gitlab.geant.org/gn4-3-wp6-t1-dpp/in_band_telemetry_bvm2/-/tree/master/int.p4app/p4src/int_v1.0).

Installation - Ubuntu 20.04
--------
1. Change the working directory to `./int_dpdk`
2. Run the prepared script `./t4p4s_bootstrap.sh`.
    * Install all necessary dependencies
    * Download compile and install [t4p4s](https://github.com/MarioKuka/t4p4s) compiler including DPDK. 

Compilation of the P4 program into the DPDK application
----
1. Change the working directory to `./int_dpdk/t4p4s/`
2. Set environment variables by running `. ./t4p4s_envvars.sh`.
3. Compile p4 program: `./t4p4s.sh [options] [path/name.p4] p4 c`
4. The compiled DPDK application is located in the `/int-dpdk/t4p4s/build/[name]@std/`

You can use the prepared script `./int_dpdk/compile_p4_to_dpdk.sh` that compiles the p4 progoram from `./int_dpdk/p4src/int_v1.0/int.p4`.

Run DPDK application
--------
1. Set up hugepages for DPDK by running `sudo ./int_dpdk/dpdk_hugepages_setup.sh -s [2048kB, 1048576kB] -c [page_num]`
2. Run DPDK applcation: `sudo ./int_dpdk/t4p4s/build/[name]@std/build/[name] [dpdk_EAL_parameters] -- [application_parameters]`

You can use the prepared script `./int_dpdk/run_dpdk_app.sh` that starts DPDK aplication `./int_dpdk/t4p4s/build/int@std/build/int` compiled by `./int_dpdk/compile_p4_to_dpdk.sh`.

TODO list 
--------
1. --

P4 implementation of INT for NFB FPGA cards 
=========
- TODO
