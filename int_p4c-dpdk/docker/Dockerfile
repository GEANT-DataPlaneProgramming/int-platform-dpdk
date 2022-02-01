FROM ubuntu

COPY ./install-dep.sh install/

RUN apt-get update
RUN chmod +x install/*
RUN ./install/install-dep.sh
RUN git clone https://github.com/GEANT-DataPlaneProgramming/int-platform-dpdk.git

RUN chmod +x ./int-platform-dpdk/int_p4c-dpdk/dpdk_hugepages_setup.sh

COPY ./swx_p4c.sh int-platform-dpdk/int_p4c-dpdk/src 

RUN chmod +x ./int-platform-dpdk/int_p4c-dpdk/src/swx_p4c.sh

CMD ["/bin/bash"]
