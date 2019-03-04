#!/bin/bash

usage() {
    echo "Usage: $0 [192.168.1.1|192.168.1.1-192.168.20.45|192.168.1.0/24]" 1>&2
    exit 1
}

ip_to_int() {
    local ip="$1"
    local w=$(echo $ip | cut -d. -f1)
    local x=$(echo $ip | cut -d. -f2)
    local y=$(echo $ip | cut -d. -f3)
    local z=$(echo $ip | cut -d. -f4)

    local int=$((256 * 256 * 256 * $w + 256 * 256 * $x + 256 * $y + $z))

    echo "$int"
}

int_to_ip() {
    local int="$1"

    local d=$(($int % 256))
    local c=$((($int - $d) / 256 % 256))
    local b=$((($int - $c - $d) / (256 * 256) % 256))
    local a=$((($int - $c - $d - $b) / (256 * 256 * 256) % 256))

    echo "$a.$b.$c.$d"
}

ping_host() {
    timeout $timeout ping -c1 $1 1>/dev/null && echo $1
}

if [ $# -ne 1 ]; then
    usage
fi

timeout=0.1

ip="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
range="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
cidr="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,2}$"

if [[ "$1" =~ $ip ]]; then
    ping_host $1
elif [[ "$1" =~ $range ]]; then
    begin=$(echo $1 | cut -d- -f1)
    end=$(echo $1 | cut -d- -f2)

    first=$(ip_to_int $begin)
    last=$(ip_to_int $end)

    for int in $(seq $first $last); do
        ping_host $(int_to_ip $int)
    done
elif [[ $1 =~ $cidr ]]; then
    net=$(echo $1 | cut -d/ -f1)
    mask=$(echo $1 | cut -d/ -f2)

    first=$(ip_to_int $net)
    last=$(( first | ((1 << (32 - mask)) - 1)))

    for int in $(seq $first $last); do
        ping_host $(int_to_ip $int)
    done
else
    usage
fi
