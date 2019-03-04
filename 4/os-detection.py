#!/usr/bin/python3
import sys
from scapy.all import *


def main():
    if len(sys.argv) < 2:
        print('No file passed, reading from STDIN')
        f = sys.stdin
    else:
        print('Reading from ' + sys.argv[1])
        f = open(sys.argv[1])

    addrs = f.read().strip().split('\n')

    for addr in addrs:
        print(addr)



if __name__ == '__main__':
    main()
