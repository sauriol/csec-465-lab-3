#!/usr/bin/python3
import sys
import argparse
from scapy.all import *


def main():
    # Set up arguments
    parser = argparse.ArgumentParser(description='An OS classification tool which differentiates between Windows and Linux')
    parser.add_argument('file', nargs='?', type=argparse.FileType('r'),
            default=sys.stdin)
    parser.add_argument('--verbose', '-v', dest='verbose', action='store_true',
            help='Print connection debugging output')
    args = parser.parse_args()

    addrs = args.file.read().strip().split('\n')

    for addr in addrs:
        if args.verbose: print('Connecting to {}'.format(addr))

        # Build ICMP packet
        rep = sr1(IP(dst=addr)/ICMP(), timeout=1, verbose=0)

        # Check TTL
        # TODO?: Give the ICMP packet a bad code and check value on return
        #   - Windows will return a valid code, Linux will return the same code
        if rep:
            if rep.ttl > 64 and rep.ttl <= 128:
                print('{}: Windows'.format(addr))
            elif rep.ttl > 32 and rep.ttl <= 64:
                print('{}: Linux'.format(addr))
            else:
                print('{}: FreeBSD'.format(addr))
        else:
            if args.verbose: print('Connection to {} failed'.format(addr))


if __name__ == '__main__':
    main()
