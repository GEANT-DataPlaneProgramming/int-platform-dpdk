#!/bin/sh
# Install dependecies
sudo apt install meson
pip3 install pyelftools
sudo apt install libdpdk-dev dpdk
sudo apt install libtre-dev

# Go to root folder to download dpdk
cd
DPDK=dpdk-21.05
DPDK_LINK=https://fast.dpdk.org/rel/$DPDK.tar.xz 
wget $DPDK_LINK
tar xf $DPDK.tar.xz
rm -f $DPDK.tar.xz

cd $DPDK

# Install dpdk
meson build
cd build
sudo ninja
sudo ninja install