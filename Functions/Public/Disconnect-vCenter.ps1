#Region VMWare.Disconnect-vCenter

<#
.SYNOPSIS
    Disconnects to vCenter Server.
.DESCRIPTION
    This function will disconnect from the specified vCenter Server.
.PARAMETER ServerName
    Unless specified this will default to the included vCenter Server.
.EXAMPLE
    VMWare.Disconnect-vCenter

    Description
    -----------
    This function will attempt to disconnect from the specified vCenter Server.
.NOTES
    AUTHOR: Sam Parris
    CREATION DATE: 11-December-2021
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
param()

Function VMWare.Disconnect-vCenter {
    [CmdletBinding()]
    Param(
        [Parameter()]$ServerName = $DefaultVIServer.Name
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        If ($ServerName) {
            Write-Host "[-] Attempting to disconnect from $ServerName" -ForegroundColor Cyan
        } Else {
            Write-Error "[X] Error vCenter server was not provided or there is no current connection."
        }
    }
    Process {
        Try {
            Disconnect-VIServer -Server $ServerName -Confirm:$false
        }
        Catch {
            Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
        }
        Write-Host "[+] Successfully Disconnected" -ForegroundColor Green
    }
}

#EndRegion VMWare.Disconnect-vCenter