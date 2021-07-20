INTERFACES="--vdev=net_tap0,iface=foo0 --vdev=net_tap1,iface=foo1"
DPDK_APP="./t4p4s/build/int@std/build/int"

sudo $DPDK_APP -c 0x3 -n 4 $INTERFACES -- -p 0x3 --config "(0,0,0),(0,1,1),(1,0,0),(1,1,1)"
