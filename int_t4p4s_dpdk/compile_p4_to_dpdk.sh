P4SRC="../p4src/int_v1.0/int.p4"
PARAMS="arch=dpdk hugepages=2048 std=p4-16 model=v1model smem cores=2 ports=2x2"

cd t4p4s
. ./t4p4s_envvars.sh
sudo rm -rf "./build/$(basename -- ${P4SRC%.*})@std"
./t4p4s.sh $PARAMS $P4SRC p4 c
