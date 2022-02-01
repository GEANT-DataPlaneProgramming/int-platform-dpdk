# INT implementation for p4c-dpdk compiler
This implementation uses P4-16 PSA model. For information about restrictions please read `Comparison.md` file in `doc/` directory

## Make it work - Ubuntu 20.04
1. Install
    a) To your system
        To install use `p4c-dpdk_bootstrap.sh` script in `int_p4c-dpdk` directory. It will:
    * Install all dependencies
    * Download and install p4c compiler
    * Download and install dpdk pipeline (interpret)

    b) Using docker
    * Build docker image in `docker` directory
    * You can run it using something like this
    ```
    sudo docker run -it --privileged -v /sys/bus/pci/drivers:/sys/bus/pci/drivers -v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages -v /sys/devices/system/node:/sys/devices/system/node -v
/dev:/dev --name dpdk-test <image-name>
    ```
2.  Set up hugepages for DPDK by running `sudo ./int_dpdk/dpdk_hugepages_setup.sh -s [2048kB, 1048576kB] -c [page_num]`
3. Run int application using `swx_p4c.sh` script in `src/`. This code does following:
    * Generates p4 file from template using `generate.py` python script.
    * Compiles this to .spec using `./p4c-dpdk int.p4 -o int.spec`
    * Starts this code by `sudo ./pipeline --vdev=net_tap,iface=int1 --vdev=net_tap2,iface=int2 -- -s int-cli` 
    Note: If you binded your device to dpdk, virtual interfaces will not active.
4. [OPTIONAL]
    Python script (for generating p4 code from template) has more parameters then `swx_p4c.sh` to try them you can first generate code by yourself and then use `-d` parameter for `swx_p4c.sh` script. This and more is also described in both files help.

### Notes
1. Sink node
    * This implementation does not support cloning therefore only one packet is produced. In default it is report packet.
2. Running code
    * All related files should be in same folder ex. all files for running source.p4 (source.spec, source-cli, source-tables) should be in one folder. This is because dpdk interpret has some problem when files are somewhere else.
    * If `swx_p4c.sh` reports that `dpdk/examples/pipeline/build/pipeline` does not exists. Make sure that it was builded.
