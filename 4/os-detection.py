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
        sent = IP(dst=addr)/ICMP()
        rep = sr1(IP(dst=addr)/ICMP(code=61), timeout=1, verbose=0)

        if rep:
            print(addr + ':')

            if rep.ttl > 64 and rep.ttl <= 128:
                print('\tWindows')
            elif rep.ttl > 32 and rep.ttl <= 64:
                print('\tLinux')



if __name__ == '__main__':
    main()
