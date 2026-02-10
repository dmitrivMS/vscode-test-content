@{
    RootModule        = 'NetworkTools.psm1'
    ModuleVersion     = '1.3.0'
    GUID              = 'a2f4c8e1-3b7d-4e9f-b5a6-1c8d2e0f4a3b'
    Author            = 'DevOps Team'
    CompanyName       = 'Example Corp'
    Description       = 'A collection of network diagnostic and monitoring utilities.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Test-PortConnection'
        'Get-DnsLookup'
        'Measure-Latency'
        'Export-NetworkReport'
    )
    CmdletsToExport   = @()
    VariablesToExport  = @()
    AliasesToExport    = @()
    PrivateData = @{
        PSData = @{
            Tags       = @('Network', 'Diagnostics', 'Monitoring')
            LicenseUri = 'https://opensource.org/licenses/MIT'
        }
    }
}
