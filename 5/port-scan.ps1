[CmdletBinding()]
param(
    [Parameter(
        ValueFromPipelineByPropertyName=$true
        ]
    [ValidateScript({$_ -match [IPAddress]$_ })]
    [string]$IPAddress,

    [Parameter(
        ValueFromPipeline=$true
    )]
    [ValidateScript({})]
    [string]$IPAdressRange,

    [Parameter(
        ValueFromPipeline=$true
    )]
    [ValidateRange(1,65535)]
    [Int32]$Port

)
