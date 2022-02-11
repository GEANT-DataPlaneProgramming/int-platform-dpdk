INTERFACES="--vdev=net_tap0,iface=foo0 --vdev=net_tap1,iface=foo1 --no-pci"
#INTERFACES="-w 0000:06:00.0 --vdev=net_tap1,iface=foo1"
DPDK_APP="./t4p4s/build/int@std/build/int"

sudo ./dpdk_hugepages_setup.sh -c 1024
sudo $DPDK_APP -c 0x1 -n 4 $INTERFACES -- -p 0x3 --config "(0,0,0),(1,0,0)"
