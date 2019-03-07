$IPone = "129.21.137.172".Split('.') 
$IPtwo = "129.21.137.200".Split('.') 

$portRange = 1..500
$timeout_ms = 5

$IPrange = ([int]$IPone[3])..([int]$IPtwo[3])

foreach($r in $IPrange)
{
    $lastOctect = [String]($r)
    $ip = "{0}.{1}.{2}.{3}" -F $IPone[0],$IPone[1],$IPone[2],$lastOctect

    if (Test-Connection -BufferSize 32 -Count 1 -Quiet -ComputerName $ip)
    {
        " "
        "=========================================================================="
        Write-Host "IP $ip is alive... checking ports..."

        foreach ($port in $portRange)
        {
            $ErrorActionPreference = 'SilentlyContinue'
            $socket = new-object System.Net.Sockets.TcpClient
            $connect = $socket.BeginConnect($ip, $port, $null, $null)
            $tryconnect = Measure-Command { $success = $connect.AsyncWaitHandle.
            WaitOne($timeout_ms, $true) } | % totalmilliseconds
            $tryconnect | Out-Null

            if ($socket.Connected)
            {
                "$ip is listening on port $port (Response Time: $tryconnect ms)"
                $socket.Close()
                $socket.Dispose()
                $socket = $null
            }
            $ErrorActionPreference = 'Continue'
        }
        "=========================================================================="
    }
    else 
    {
        " "
        "=========================================================================="
        Write-Host "IP $ip has no connection..."
        "=========================================================================="
    }
}
