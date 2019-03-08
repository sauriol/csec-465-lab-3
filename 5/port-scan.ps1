param (
    [Parameter(Mandatory=$true)]$AddressRange,
    [Parameter(Mandatory=$true)]$PortRange
)

# Build list of IP addresses from a given begin and end address
function IP-Range {
    param (
        [parameter(Mandatory=$true, Position=0)][System.Net.IPAddress]$Begin,
        [parameter(Mandatory=$true, Position=1)][System.Net.IPAddress]$End
    )

    $ip1 = $Begin.GetAddressBytes()
    [Array]::Reverse($ip1)
    $ip1 = ([System.Net.IPAddress]($ip1 -join '.')).Address

    $ip2 = $End.GetAddressBytes()
    [Array]::Reverse($ip2)
    $ip2 = ([System.Net.IPAddress]($ip2 -join '.')).Address

    for ($x = $ip1; $x -le $ip2; $x++) {
        $ip = ([System.Net.IPAddress]$x).GetAddressBytes()
        [Array]::Reverse($ip)
        $ip -join '.'
    }
}

# Build list of IP address from CIDR notation
function CIDR-Range {
    param (
        [parameter(Mandatory=$true, Position=0)][System.Net.IPAddress]$Begin,
        [parameter(Mandatory=$true, Position=1)][int]$CIDR
    )

    $bytes = $Begin.GetAddressBytes()
    [Array]::Reverse($bytes)

    $ip1 = [uint32]([System.Net.IPAddress]$bytes).Address

    $End = ([System.Net.IPAddress](($ip1 -bor (1 -shl (32 - $CIDR))) - 1)).GetAddressBytes()

    $ip2 = [uint32]([System.Net.IPAddress]$End).Address

    for ($x = $ip1; $x -le $ip2; $x++) {
        $ip = ([System.Net.IPAddress]$x).GetAddressBytes()
        [Array]::Reverse($ip)
        $ip -join '.'
    }
    
}

# 1 IP case
if ($AddressRange -match '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$') {
    $Addrs = IP-Range -Begin $AddressRange -End $AddressRange
}
# Range case
ElseIf ($AddressRange -match '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$') {
    $range = $AddressRange -split '-'
    $Addrs = IP-Range -Begin $range[0] -End $range[1]
}
# CIDR case
ElseIf ($AddressRange -match '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,2}$') {
    $cidr = $AddressRange -split '/'
    $Addrs = CIDR-Range $cidr[0] $cidr[1]
}
# die if anything else
Else {
    Write-Output 'Error: $AddressRange must be a valid range'
    exit 1
}

# 1 port case - has to come first
If ($PortRange -match '^\d*$') {
    $Ports = @($PortRange)
}
# List case
ElseIf ($PortRange -match '^([\d+]+,*)*$') {
    $Ports = @($PortRange -split ',')
}
# Range case
ElseIf ($PortRange -match '^\d*-\d*$') {
    $range = $PortRange -split '-'
    $Ports = ($range[0]..$range[1])
}
# Die if anything else
Else {
    Write-Output 'Error: $PortRange must be a valid range'
    exit 2
}

# Actually scan the ports + addresses
foreach ($addr in $Addrs) {
    If (Test-Connection -BufferSize 32 -Count 1 -Quiet -ComputerName $addr) {
        Write-Output "IP $addr is alive, checking ports..."

        # TCP only for now
        # TODO?: add UDP
        foreach ($port in $Ports) {
            $ErrorActionPreference = 'SilentlyContinue'
            $socket = new-object System.Net.Sockets.TcpClient
            $socket.Connect($addr, $port)

            if ($socket.Connected) {
                Write-Output "`tPort $port is open"

                $socket.Close()
                $socket.Dispose()
                $socket = $null
            }
        }
    }
    Else {
        Write-Output "IP $addr is dead"
    }
}
