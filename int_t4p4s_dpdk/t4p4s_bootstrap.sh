sudo apt update
sudo apt install -y clang cmake meson gdb net-tools
git clone --recursive https://github.com/GEANT-DataPlaneProgramming/t4p4s.git
cd t4p4s
DPDK_VSN=20.11
DPDK_VSN=20.11 DPDK_VERSION=20.11 DPDK_FILEVSN=20.11.3 REPO_PATH_p4c=https://github.com/GEANT-DataPlaneProgramming/p4c INSTALL_STAGE5_GRPC=no PARALLEL_INSTALL=no . ./bootstrap-t4p4s.sh
