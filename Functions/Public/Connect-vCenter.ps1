#Region VMWare.Connect-vCenter

<#
.SYNOPSIS
    Connects to vCenter Server.
.DESCRIPTION
    This function will create a connection to the specified vCenter server.
.PARAMETER ServerName
    Unless specified this will default to the included vCenter Server.
.EXAMPLE
    VMWare.Connect-vCenter

    Description
    -----------
    This function will prompt for a Username and Password, and then attempt to connect you to the vCenter server.
.NOTES
    AUTHOR: Sam Parris
    CREATION DATE: 10-December-2021
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
param()

Function VMWare.Connect-vCenter {
    [CmdletBinding()]
    Param(
        [Parameter()]$ServerName = '10.20.105.247'
    )
    Begin {
        Write-Host "[-] Attempting Connection to $ServerName" -ForegroundColor Cyan
        $Script:VIServerCredentials = Get-Credential
    }
    Process {
        $ConnectionParams = @{
            Server     = $ServerName
            Credential = $Script:VIServerCredentials
        }
        Try {
            Connect-VIServer @ConnectionParams | Out-Null
        }
        Catch {
            Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
        }
    }
    End {
        If ($DefaultVIServer) {
            Write-Host "[+] Connected to $($DefaultVIServer.Name) using $($DefaultVIServer.User)" -ForegroundColor Green
        }
        Else {
            Write-Host "[X] Unable to connect to $ServerName using $($Script:VIServerCredentials.UserName)" -ForegroundColor Red
        }
    }
}