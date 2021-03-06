#!/bin/sh
# 
#  Copyright 2020 PSNC
# 
#  Author: Pavlína Patová
# 
#  Created in the GN4-3 project.
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# 
#
#  /////////////////////////////////////////////////////////////////////////////////////////////////////////


usage() { 
    echo "Each node needs to have its own folder which contains" 
    echo "\t*p4 code\n"
    echo "\t*cli code. \n\t\tIt needs to have same name as p4 code + -cli sufix. ex. source.p4 -> source-cli\n"
    echo "\t*tables. This is optional and depends on cli code"

    echo "This script uses generate.py which have some other functions. If you want to first generate p4 code using that script, you can do so. Then you just can use -d parameter to simply run and compile custom generated code."
    echo "Usage: $0 -s node_name [-c] [-r] [-a] [-t number] [-p pcap]\n"
    echo "\t -s == Name of the node ex.source, transit, sink"
    echo "\t -c == If this flag is present. Code is only compiled"
    echo "\t -r == If this flag is present. Code is only executed"
    echo "\t -a == If this flag is present. Whole pipeline will be executed"
    echo "\t Following atributes have meaning only if -a was used"
    echo "\t\t -t == Determines how many transit nodes will be applied"
    echo "\t\t -p == Path to the first packet"
    echo "\tWARNING \n\t\t-c and -r cannot be used at same time \n\t\tAlso if -a is present, both -c and -r will be ignored"
    echo "\t -m == Destination mac address. Used only for transit. \n\t\tNote: mac address 0xffffffffffff (BC) has special meaning -> mac address will not be changed. \n\t\tThis value is used as default"
    echo "\t -n == Max nodes"
    echo "\t -d == P4 will not be generated (from templates)"

    exit 1;
}

compile() {
    cd $SRC

    REPARE="yes"
    # When header stack is used this needs to execute. Now SRC will never be "sink" because it will change its name to int.
    if [ $REPARE = "yes" ] && [ $SRC = "sink" ]
    then
        SPEC_FILE="tmp.not-spec"
    else
        SPEC_FILE="$SRC.spec"
        REPARE="no"
    fi

    echo "\n\033[36mCompiling... $SRC.p4 to $SPEC_FILE\033[0m\n"
    $P4C $SRC.p4 -o $SPEC_FILE
    RET=$?

    if [ $RET -eq 0 ] && [ $REPARE = "yes" ]
    then
        echo "\033[31mReparing spec file\033[0m"
        `rm -f $SRC.spec`
        while IFS= read -r line; do
            LINE=`echo $line | xargs`
            if [ "$LINE" = "add m.local_metadata_hops 0xff" ]
            then
                echo "\tsub m.local_metadata_hops 0x1" >> "$SRC.spec"
            elif [ "$LINE" = "verify 0 error.StackOutOfBounds" ]
            then
                echo ""
            elif [ "$LINE" = "add m.local_metadata_hops_16 0xffff" ]
            then
                echo "\tsub m.local_metadata_hops_16 0x1" >> "$SRC.spec"
            else
                echo "$line" >> "$SRC.spec"
            fi
        done < $SPEC_FILE
    `rm -f tmp.not-spec`
    fi

    if [ $RET -ne 0 ]
    then
        echo "\033[31mCompilation ERROR\033[0m"
        exit 1
    fi

    cd ../
}

run() {
    DISTANT=$1
    cd $SRC

    # Interface setup
    #IFC0="--vdev=net_tap,iface=int_primo"
    IFC1="--vdev=net_tap3,iface=$FIRST_IFC"
    IFC2="--vdev=net_tap2,iface=$SECOND_IFC"
    # PARAM="$IFC0 $IFC1 $IFC2"
    PARAM="$IFC1 $IFC2"

    # Configuration parametrs
    # More in dpdk documentation
    CONF="-s $SRC-cli"

    echo "\n\033[36mRunning $SRC-cli\033[0m\n"
    if [ $DISTANT -eq 0 ]
    then
        sudo $PIPE $PARAM -- $CONF 
    else
        sudo $PIPE $PARAM -- $CONF &
    fi

    PID=$!

    cd ../
}

run_all() {
    SRC=$1
    PCAP_IN=$2
    PCAP_OUT="$SRC$CNT.pcap"

    echo "\033[33m$1\033[0m"
    # Compile and run our program
    compile
    run 1

    # Setup catching
    sleep 5
    
    # DUMP
    if [ $SRC = "sink" ]
    then
        echo "\033[33mtcpdump -c 10 -i $OUT_IFC -XX &\033[0m"
        sudo tcpdump -c 10 -i $OUT_IFC -XX &
    else
        echo "\033[33mtcpdump -c 1 -w $PCAP_OUT -i $OUT_IFC $OPTIONS &\033[0m"
        sudo tcpdump -c 1 -w $PCAP_OUT -i $OUT_IFC $OPTIONS &
    fi

    sleep 1

    # REPLAY
    CODE="tcpreplay -i $IN_IFC $PCAP_IN"

    echo "\033[33m$CODE\033[0m"
    sudo $CODE

    if [ $OLD = "sink" ]
    then
        sleep 5
    else
        sleep 2
    fi
    # Kill running dpdk pipeline
    #@!#
    PID_RAW=`ps aux | grep dpdk/examples/pipeline | grep Rl`
    PID=`echo $PID_RAW | awk '{print$2}'`
    sudo kill -9 $PID
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# !!!~~~~~~~~~~~~ MAIN() ~~~~~~~~~~~~!!!
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SRC="source"
COMPILE_ONLY=0
RUN_ONLY=0
RUN_ALL=0
TRAN_CNT=1
PCAP_IN="udp.pcap"
NODE_CNT=4
MAC_ADDR="0xffffffffffff"
GEN_EN=1
OPTIONS="" # "dst port 42"

FIRST_IFC="int1"
SECOND_IFC="int2"

# Path to compiler
P4C="../../p4c/build/p4c-dpdk"

# Path to interpret
# WARNING if "dpdk-21.05/examples/pipeline" part is changed code after this @!# also needs to be changed
PIPE="../../dpdk/examples/pipeline/build/pipeline"

while getopts "s:crat:p:m:n:d" o; do
    case "${o}" in
        s)
            SRC=${OPTARG}
            ;;
        c)
            COMPILE_ONLY=1
            ;;
        r)
            RUN_ONLY=1
            ;;
        a)
            RUN_ALL=1
            ;;
        t)
            TRAN_CNT=${OPTARG}
            ;;
        p)
            PCAP_IN=${OPTARG}
            ;;
        m)
            MAC_ADDR=${OPTARG}
            ;;
        n)
            NODE_CNT=${OPTARG}
            ;;
        d)
            GEN_EN=0
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

if [ $COMPILE_ONLY -eq 1 ] && [ $RUN_ONLY -eq 1 ]
then
    echo "You cannot use -c and -r at same time"
    exit 1
fi

if [ $TRAN_CNT -gt $NODE_CNT ]
then
    echo "Number of transit nodes cannot be higher then max nodes"
    exit 1
fi

# All nodes
if [ $RUN_ALL -eq 1 ]
then
    # Common variables
    CNT=0 

    # SOURCE
    if [ $GEN_EN -eq 1 ]
    then
        python3 generate.py -r -c -n $NODE_CNT -m $MAC_ADDR
    fi

    # In CLI IN and OUT ifc are swapped
    IN_IFC=$SECOND_IFC
    OUT_IFC=$FIRST_IFC

    run_all source $PCAP_IN $CNT

    # IN_IFC=$FIRST_IFC
    # OUT_IFC=$SECOND_IFC

    

    # TRANSIT
    if [ $GEN_EN -eq 1 ]
    then
        python3 generate.py -t -n $NODE_CNT -m $MAC_ADDR
    fi

    while [ $CNT -ne $TRAN_CNT ]
    do
        if [ $CNT -eq 0 ]
        then
            

            run_all transit source$CNT.pcap  $CNT
        else
            

            run_all transit transit$((CNT-1)).pcap  $CNT
        fi
        CNT=$((CNT+1))
    done

    # SINK
    if [ $GEN_EN -eq 1 ]
    then
        python3 generate.py -s -n $NODE_CNT -m $MAC_ADDR
    fi

    run_all sink    transit$((TRAN_CNT-1)).pcap $CNT

# Single node
else
    OLD=$SRC
    if [ $SRC = "transit" -o $SRC = "sink" -o $SRC = "source" ]
    then
        OLD=$SRC
        SRC="int"
    fi

    if [ $GEN_EN -eq 1 ]
    then
        if [ $OLD = "transit" ]
        then
            python3 generate.py -r -t -n $NODE_CNT -m $MAC_ADDR
        
        elif [ $OLD = "sink" ]
        then
            python3 generate.py -r -s -n $NODE_CNT -m $MAC_ADDR

        elif [ $OLD = "source" ]
        then
            python3 generate.py -r -c -n $NODE_CNT -m $MAC_ADDR
            
        else
            python3 generate.py -r -n $NODE_CNT
        fi

    fi

    # Compile code if it is allowed
    if [ $RUN_ONLY -ne 1 ]
    then
        compile
    fi

    # Run code if it is allowed
    if [ $COMPILE_ONLY -ne 1 ]
    then
        run 0
    fi
fi

exit 0