#!/bin/bash
# Copyright(c) 2010-2014 Intel Corporation
# Copyright(c) 2019-2020 CESNET, z.s.p.o.
# Inspired by dpdk-setup.sh

hugepages_size()
{
	cat /proc/meminfo  | grep Hugepagesize | cut -d : -f 2 | tr -d ' '
}

report()
{
	echo "$@" >&2
}

remove_mnt_huge()
{
	report "Unmounting /mnt/huge and removing directory"
	grep -s '/mnt/huge' /proc/mounts > /dev/null
	if [ $? -eq 0 ] ; then
		umount /mnt/huge
	fi

	if [ -d /mnt/huge ] ; then
		rm -R /mnt/huge
	fi
}

check_permissions()
{
	local HUGEPGSZ="$1"

	for d in /sys/devices/system/node/node? ; do
		if [ ! -w "$d/hugepages/hugepages-${HUGEPGSZ}/nr_hugepages" ]; then
			report "Not enough permissions, consider sudo or su"
			report `id`
			exit -1
		fi
	done
}

clear_huge_pages()
{
	local HUGEPGSZ="$1"

	echo > .echo_tmp
	for d in /sys/devices/system/node/node? ; do
		echo "echo 0 > $d/hugepages/hugepages-${HUGEPGSZ}/nr_hugepages" >> .echo_tmp
	done
	report "Removing currently reserved hugepages"
	sh .echo_tmp
	rm -f .echo_tmp
}

create_mnt_huge()
{
	local HUGEPGSZ="$1"

	report "Creating /mnt/huge and mounting as hugetlbfs"
	mkdir -p /mnt/huge

	grep -s '/mnt/huge' /proc/mounts > /dev/null
	if [ $? -ne 0 ] ; then
		mount -t hugetlbfs nodev /mnt/huge -o pagesize="${HUGEPGSZ}"
	fi
}

set_non_numa_pages()
{
	local Pages="$1"
	local HUGEPGSZ="$2"
	AllocOnly="$3"

	check_permissions "${HUGEPGSZ}"
	clear_huge_pages "${HUGEPGSZ}"

	if [ "${AllocOnly}" = "0" ]; then
		remove_mnt_huge
	fi

	echo "echo $Pages > /sys/kernel/mm/hugepages/hugepages-${HUGEPGSZ}/nr_hugepages" > .echo_tmp
	report "Reserving $Pages hugepages ${HUGEPGSZ}"
	sh .echo_tmp
	rm -f .echo_tmp

	if [ "${AllocOnly}" = "0" ]; then
		create_mnt_huge "${HUGEPGSZ}"
	fi
}

set_numa_pages()
{
	local Pages="$1"
	local HUGEPGSZ="$2"
	AllocOnly="$3"

	check_permissions "${HUGEPGSZ}"
	clear_huge_pages "${HUGEPGSZ}"

	if [ "${AllocOnly}" = "0" ]; then
		remove_mnt_huge
	fi

	echo > .echo_tmp
	for d in /sys/devices/system/node/node? ; do
		echo "echo $Pages > $d/hugepages/hugepages-${HUGEPGSZ}/nr_hugepages" >> .echo_tmp
	done

	report "Reserving $Pages hugepages ${HUGEPGSZ}"
	sh .echo_tmp
	rm -f .echo_tmp

	if [ "${AllocOnly}" = "0" ]; then
		create_mnt_huge "${HUGEPGSZ}"
	fi
}

supported_hugepage_sizes()
{
	local sizes=""

	if [ ! -d /sys/kernel/mm/hugepages ]; then
		return
	fi

	for name in `ls /sys/kernel/mm/hugepages`; do
		sz=`sed 's/^[^-]*-//' <<< "${name}"`

		if [ -z "${sizes}" ]; then
			sizes="${sz}"
		else
			sizes="${sizes}, ${sz}"
		fi
	done

	echo "${sizes}"
}

print_help()
{
	report "Usage: $0 -c<hugepg-count> [-s<hgpage-size>] [-n]"
	report "Options:"
	report "  -c<number> - count of hugepages to reserve"
	report "  -s<size>   - hugepages size to reserve (see contents of /sys/kernel/mm/hugepages)"
	report "  -n         - allocate for NUMA (default is non-NUMA)"
}

HUGEPGSZ=`hugepages_size`
Numa=0
AllocOnly=0

while getopts 'c:s:nha' c; do
	case $c in
	c)
		Pages=$OPTARG
	;;
	s)
		HUGEPGSZ=$OPTARG
	;;
	n)
		Numa=1
	;;
	a)
		AllocOnly=1
	;;
	h)
		print_help
		exit 0
	;;
	esac
done

if [ -z "$Pages" ]; then
	report "Please, specify number of hugepages to reserve (-c)"
	exit -1
fi

if [ ! -d "/sys/kernel/mm/hugepages/hugepages-${HUGEPGSZ}" ]; then
	report "Unsupported hugepages size (${HUGEPGSZ}), supported: `supported_hugepage_sizes`"
	exit -1
fi

if [ "$Numa" = "1" ]; then
	set_numa_pages "$Pages" "$HUGEPGSZ" "$AllocOnly"
else
	set_non_numa_pages "$Pages" "$HUGEPGSZ" "$AllocOnly"
fi
