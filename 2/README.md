# dns-enumeration.sh

```
Usage: dns-enumeration.sh [-4|-6] [-l] [-e] hosts-file
```

A script to return a list of IP addresses given a file containing a list of host
names. Resolves hostnames using `getent`. By default, it uses `getent ahosts`,
but `-4` and `-6` can be used to specify `ahostsv4` or `ahostsv6`.

## Options
`-4`
  - Resolves only IPv4 addresses

`-6`
  - Resolves only IPv6 addresses

`-l`
  - Long output, prints "$name: $addr1 $addr2 ..."

`-e`
  - Prints errors - if a host is not found, prints "Error: no entry for $name"
