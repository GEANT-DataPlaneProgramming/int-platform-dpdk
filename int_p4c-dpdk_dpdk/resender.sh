#!/bin/sh
usage() { 
    echo "Usage: $0 -i in_ifc -o out_ifc [-p \"options_for_in_ifc\"] [-n pcap_name] [-c number_of_cycles] [-s time] [-l time]\n" 1>&2; 
    echo "\t -i == Interface for tcpdump\n"
    echo "\t -o == Interface for tcreplay\n"
    echo "\t -p == Options for tcpdump\n"
    echo "\t -n == Name of the pcap\n"
    echo "\t -c == How many times should we repeat resending !WARNING pcap name is still the same therefore will be overwritten\n\t\tFor infinit loop, insert 0\n"
    echo "\t -s == Sleep time before tcpdump\n"
    echo "\t -l == Sleep time before tcpreplay\n"
    echo "\t -k == Set sink flag to true\n"

    exit 1;
}


IN="int_out"
OUT="enp1s0"
OPTIONS="port 42"
PCAP_NAME="tmp.pcap"
CYCLE=1
DUMP_SLEEP=0
REPLAY_SLEEP=0
IS_SINK=0

while getopts "i:o:p:n:chs:l:k" o; do
    case "${o}" in
        i)
            IN=${OPTARG}
            ;;
        o)
            OUT=${OPTARG}
            ;;
        p)
            OPTIONS=${OPTARG}
            ;;
        n)
            PCAP_NAME=${OPTARG}
            ;;
        c)
            CYCLE=${OPTARG}
            ;;  
        s)
            DUMP_SLEEP=${OPTARG}
            ;;
        l)
            REPLAY_SLEEP=${OPTARG}
            ;;
        k)
            IS_SINK=1
            ;;
        h) 
            usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

while [ true ]
do
    if [$IS_SINK -eq 1 ]
    then
        echo "\033[33m Running:     sudo tcpdump -i $IN -c 1 -w $PCAP_NAME $OPTIONS \033[0m\n"
        sudo tcpdump -i $IN -c 1 -w $PCAP_NAME $OPTIONS 
    fi

    echo "\033[32m Sleep $DUMP_SLEEP \033[0m\n"
    sleep $DUMP_SLEEP
    echo "\033[33m Running:     sudo tcpdump -i $IN -c 1 -w $PCAP_NAME $OPTIONS \033[0m\n"
    sudo tcpdump -i $IN -c 1 -w $PCAP_NAME $OPTIONS 

    echo "\033[32m Sleep $REPLAY_SLEEP \033[0m\n"
    sleep $REPLAY_SLEEP
    echo "\033[34m Running:     sudo tcpreplay -i $OUT $PCAP_NAME \033[0m\n"
    sudo tcpreplay -i $OUT $PCAP_NAME
    
    CYCLE=$(($CYCLE-1))
    if [ $CYCLE -eq 0 ]
    then
        exit 0
    fi

done