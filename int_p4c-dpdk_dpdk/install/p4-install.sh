# git clone --recursive https://github.com/p4lang/p4c.git
cd ../p4c/
mkdir build
cd build
cmake ..
make -j4
make -j4 check
sudo make install