#!/bin/sh
cd
DPDK_LINK=https://fast.dpdk.org/rel/dpdk-21.05.tar.xz 
wget $DPDK_LINK
#tar xf dpdk.tar.gz
#cd dpdk
sudo apt install meson
pip3 install pyelftools
meson build
cd build
sudo apt install libdpdk-dev dpdk
sudo ninja
sudo ninja install
sudo apt install libtre-dev
