function Test-PortConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Hostname,

        [Parameter(Mandatory)]
        [int[]]$Ports,

        [int]$TimeoutMs = 2000
    )

    process {
        foreach ($port in $Ports) {
            $tcp = New-Object System.Net.Sockets.TcpClient
            try {
                $result = $tcp.BeginConnect($Hostname, $port, $null, $null)
                $success = $result.AsyncWaitHandle.WaitOne($TimeoutMs)
                [PSCustomObject]@{
                    Hostname = $Hostname
                    Port     = $port
                    Open     = $success
                }
            }
            catch {
                [PSCustomObject]@{
                    Hostname = $Hostname
                    Port     = $port
                    Open     = $false
                }
            }
            finally {
                $tcp.Dispose()
            }
        }
    }
}

Export-ModuleMember -Function Test-PortConnection
