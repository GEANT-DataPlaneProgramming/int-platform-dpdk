#!/bin/sh
echo $#
if [ $# -lt 1 ]
then
    RUN="no"
else
    RUN=$1
fi
echo $RUN

mountpoint -q /dev/hugepages || mount -t hugetlbfs nodev /dev/hugepages
sudo su << RUN
echo 2048 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
exit
RUN

if [ $RUN != "yes" ] 
then
    sudo modprobe uio_pci_generic
fi
