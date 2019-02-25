#!/bin/bash
# A DNS enumeration tool that takes a file containing a list of hostnames and
# returning the IP addresses of the hosts
#
# TODO
#   - Add option parsing
#       - Different output modes (just addressess, addresses with errors, ...)

usage() { echo "Usage: $0 [-4|-6] [-l] [-e] hosts-file" 1>&2; exit 1; }

hosts="ahosts"
mode="short"
errors=1

while getopts "46le" opt; do
    case ${opt} in
        4 )
            hosts="ahostsv4"
            ;;
        6 )
            hosts="ahostsv6"
            ;;
        l )
            mode="long"
            ;;
        e )
            errors=0
            ;;
        \? )
            echo "Err: arg not recognized"
            usage
            ;;
    esac
done

shift $((OPTIND - 1))

if [ "$#" -ne 1 ]; then
    echo "Err: not enough args"
    usage
fi

while read line; do
    addrs=$(getent $hosts $line | awk '{ print $1 }' | uniq)

    if [ -z "$addrs" ]; then
        if [ $errors -eq 0 ]; then
            (echo "Error: no entry for $line" 1>&2)
        fi
    else
        if [ $mode == "long" ]; then
            echo $line: $addrs
        elif [ $mode == "short" ]; then
            echo "$addrs"
        fi
    fi

done < $1
