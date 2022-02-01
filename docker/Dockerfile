FROM ubuntu

COPY ./install-dep.sh install/

RUN apt-get update
RUN chmod +x install/*
RUN ./install/install-dep.sh
RUN git clone https://github.com/GEANT-DataPlaneProgramming/int-platform-dpdk.git

RUN chmod +x ./int-platform-dpdk/int_p4c-dpdk/dpdk_hugepages_setup.sh
RUN ./int-platform-dpdk/int_p4c-dpdk/dpdk_hugepages_setup.sh -c 2048 -s 512

RUN cd ./int-platform-dpdk/int_p4c-dpdk/

CMD ["/bin/bash"]
