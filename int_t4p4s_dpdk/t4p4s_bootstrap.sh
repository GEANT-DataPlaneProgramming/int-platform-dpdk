sudo apt install -y clang cmake meson gdb net-tools
git clone --recursive https://github.com/MarioKuka/t4p4s.git
cd t4p4s
REPO_PATH_p4c=https://github.com/MarioKuka/p4c INSTALL_STAGE5_GRPC=no PARALLEL_INSTALL=no . ./bootstrap-t4p4s.sh
