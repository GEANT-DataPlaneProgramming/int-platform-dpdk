#!/bin/sh

# Install dependecies
INSTALL="
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
"
for i in $INSTALL
do
    sudo apt-get install $i -y
done

pip3 install scapy ply
pip3 install pyelftools

# P4C Install
cd ..
git clone --single-branch --branch stable --recursive https://github.com/Patovap/p4c.git 
cd p4c/
mkdir build
cd build
cmake ..
make -j4
make -j4 check
sudo make install

# DPDK Install
cd ../../
git clone --single-branch --branch stable --recursive https://github.com/Patovap/dpdk.git
cd dpdk
meson build
cd build
sudo ninja
sudo ninja install

# Make pipeline example
cd ../examples/pipeline
make

sudo ldconfig