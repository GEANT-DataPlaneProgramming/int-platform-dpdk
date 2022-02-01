#!/bin/sh

# Install dependecies
INSTALL="
net-tools
vim
cmake 
g++ 
git 
automake 
libtool 
libgc-dev 
bison 
flex 
libfl-dev 
libgmp-dev 
libboost-dev  
libboost-iostreams-dev 
libboost-graph-dev  
llvm  
pkg-config  
python  
python-scapy 
python-ipaddr  
python-ply  
python3-pip  
tcpdump 
meson
libdpdk-dev dpdk
libtre-dev
protobuf-compiler libprotobuf-dev
tcpreplay

libhugetlbfs-utils
libpcap-devel
kernel
kernel-devel
kernel-headers

pciutils
autoconf 
expect
"
for i in $INSTALL
do
    apt-get install $i -y
done

pip3 install scapy ply
pip3 install pyelftools
pip3 install jinja2
# P4C Install
    git clone --single-branch --branch stable --recursive https://github.com/GEANT-DataPlaneProgramming/p4c 
    cd p4c/
    mkdir build
    cd build
    cmake ..
    make -j4
    make -j4 check
    make install
    cd
# DPDK Install
    git clone --single-branch --branch stable --recursive https://github.com/GEANT-DataPlaneProgramming/dpdk.git
    cd dpdk
    meson build
    cd build
    ninja
    ninja install

# Make pipeline example
    cd ../examples/pipeline
    make

    ldconfig
