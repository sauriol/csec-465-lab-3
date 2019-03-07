# This scans common ports in a range of IPs for web servers and reports back which type of web server is on that port
import sys
import threading
import socket
import ssl
import re

ports = [80,443,8080]

context = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
context.verify_mode = ssl.CERT_REQUIRED
context.check_hostname = True
context.load_default_certs()


def connector(host, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(2)
    try:
        s.connect((str(host), port))
        s.sendall(('GET / HTTP/1.1\r\nHost: ' + str(host) + '\r\n\r\n').encode())
        response = s.recv(100000).decode().split('\r\n')
        s.close()
    except:
        return
    for x in response:
        server = re.match(r'Server: .*', x)
        if server:
            print(x[8:] + ' on ' + str(host) + ':' + str(port))
            return
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(2)
    s = context.wrap_socket(s, server_hostname=host)
    try:
        s.connect((str(host), port))
        s.sendall(('GET / HTTP/1.1\r\nHost: ' + str(host) + '\r\n\r\n').encode())
        response = s.recv(100000).decode().split('\r\n')
        s.close()
    except:
        return
    for x in response:
        server = re.match(r'Server: .*', x)
        if server:
            print(x[8:] + ' on ' + str(host) + ':' + str(port))
            return

    print('Found on ' + str(port))


def main():
    if len(sys.argv) == 1 or len(sys.argv) > 4:
        print('Invalid usage. Type \'webserverenum -h\' for proper usage.')
        exit(1)
    else:
        if sys.argv[1] == '-h':
            print('webserverenum: a python3 based web scanner that determines the type of web server used on a given'
                  ' host by checking ports 80, 443, and 8080')
            print('Usage: \'python3 webserverenum [mode flag] [start/single host] [end host] ')
            print('Example: python3 webserverenum -i 192.168.0.100\r\n')
            print('Mode flags:')
            print('\t-h:\tDisplays this message. Ignores all other arguments')
            print('\t-i:\tScans a single IP and only takes in the single host argument afterwards')
            print('\t-r:\tScans a range of IPs and takes in both the start and end host arguments')
            print('\t-d:\tScans a single DNS address and takes in only the single host argument\r\n')
            print('Exit codes:')
            print('\t0: webserverenum has run successfully')
            print('\t1: webserverenum exited due to input error')
            print('\t2: webserverenum exited due to internal error. Contact maintainer about what went wrong and how')
        elif sys.argv[1] == '-i' and len(sys.argv) == 3:
            host = sys.argv[2]
            ip = host.split('.')
            x = 0
            while x < 4:
                try:
                    ip[x] = int(ip[x])
                except ValueError:
                    print('Invalid IP. Type \'webserverenum -h\' for proper usage.')
                    exit(1)
                if ip[x] < 0 or ip[x] > 254:
                    print('Invalid IP. Type \'webserverenum -h\' for proper usage.')
                    exit(1)
                x += 1
            for port in ports:
                t = threading.Thread(target=connector, args=(host, port))
                t.start()
        elif sys.argv[1] == '-d' and len(sys.argv) == 3:
            host = sys.argv[2]
            for port in ports:
                t = threading.Thread(target=connector, args=(host, port))
                t.start()
        elif sys.argv[1] == '-r' and len(sys.argv) == 4:
            start = sys.argv[2].split('.')
            end = sys.argv[3].split('.')
            if len(start) != 4 or len(end) != 4:
                print('Invalid usage. Type \'webserverenum -h\' for proper usage.')
                exit(1)
            else:
                x = 0
                while x < 4:
                    try:
                        start[x] = int(start[x])
                    except ValueError:
                        print('Invalid IP. Type \'webserverenum -h\' for proper usage.')
                        exit(1)
                    if start[x] < 0 or start[x] > 254:
                        print('Invalid IP. Type \'webserverenum -h\' for proper usage.')
                        exit(1)
                    try:
                        end[x] = int(end[x])
                    except ValueError:
                        print('Invalid IP. Type \'webserverenum -h\' for proper usage.')
                        exit(1)
                    if end[x] < 0 or end[x] > 254:
                        print('Invalid IP. Type \'webserverenum -h\' for proper usage.')
                        exit(1)
                    x += 1
            while start[0] <= end[0]:
                while start[1] <= end[1]:
                    while start[2] <= end[2]:
                        while start[3] <= end[3]:
                            for port in ports:
                                t = threading.Thread(target=connector, args=(str(start[0]) + '.' + str(start[1]) + '.' +
                                                                                 str(start[2]) + '.' + str(start[3]),
                                                                             port))
                                t.start()
                            start[3] += 1
                        start[2] += 1
                    start[1] += 1
                start[0] += 1
    exit(0)

main()
