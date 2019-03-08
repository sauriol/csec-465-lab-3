# webserverenum.py

```
webserverenum: a python3 based web scanner that determines the type of web server used on a given host by checking ports 80, 443, and 8080
Usage: 'python3 webserverenum [mode flag] [start/single host] [end host]
Example: python3 webserverenum -i 192.168.0.100

Mode flags:
        -h:     Displays this message. Ignores all other arguments
        -i:     Scans a single IP and only takes in the single host argument afterwards
        -r:     Scans a range of IPs and takes in both the start and end host arguments
        -d:     Scans a single DNS address and takes in only the single host argument

Exit codes:
        0: webserverenum has run successfully
        1: webserverenum exited due to input error
        2: webserverenum exited due to internal error. Contact maintainer about what went wrong and how

```

Webserverenum scans common web server ports in either a single IP, a range of IPs, or a single DNS address and reports back what types of webserver exist on what hosts and ports if any.
