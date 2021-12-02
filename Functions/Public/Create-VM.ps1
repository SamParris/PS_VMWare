<#
.SYNOPSIS
    Creates a new VM.
.DESCRIPTION
    This function creates a new VM within the vCenter.
.NOTES
    AUTHOR: Sam Parris
    CREATION DATE: 01-December-2021
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
param()

Function VMWare.Create-VM {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)] $NewVMName,
        [Parameter()] [int] $MemoryGB = '4',
        [Parameter()] [int] $NumCPU = '2',
        [Parameter()] [int] $CoresPerSocket = $NumCPU,
        [Switch] $PowerOn,
        [Switch] $Connect
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        If ($Global:DefaultVIServer) {
            Write-Host "[+] Connected to $($Global:DefaultVIServer.Name) as $($Global:DefaultVIServer.User)" -ForegroundColor Green
        }
        Else {
            Write-Error "[X] You must be connected to a VIServer to run this function."
        }
    }
    Process {
        $NewVMParams = @{
            Name           = $NewVMName
            MemoryGB       = $MemoryGB
            NumCPU         = $NumCPU
            CoresPerSocket = $CoresPerSocket
            CD             = $true
            GuestID        = 'windows2019srv_64Guest'
        }
        Try {
            Write-Host "[-] Creating new VM - $($NewVMName) ($CoresPerSocket vCPU, $MemoryGB GB)" -ForegroundColor Cyan
            New-VM @NewVMParams | Out-Null
        }
        Catch {
            Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
        }
        If ($PowerOn.IsPresent) {
            Try {
                Write-Host "[-] Powering on VM - $($NewVMName)" -ForegroundColor Cyan
                Start-VM -VM $NewVMName | Out-Null
            }
            Catch {
                Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
            }
        }
        If ($Connect.IsPresent) {
            If ($PowerOn.IsPresent) {
                Try {
                    Write-Host "[-] Initiating remote connection to VM - $($NewVMName)" -ForegroundColor Cyan
                    Open-VMConsoleWindow -VM $NewVMName
                }
                Catch {
                    Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
                }
            }
            Else {
                Write-Host "[!] VM is not powered on. You must specify -PowerOn inorder to open a console using -Connect" -ForegroundColor Yellow
            }
        }
    }
    End {
        $CreatedVM = Get-VM | Where-Object { $_.Name -eq $NewVMName }
        If (-Not($CreatedVM)) {
            Write-Error "[X] VM not created, please check vCenter before running this function again."
        }
        Else {
            Write-Host "[+] $NewVMName has been created" -ForegroundColor Green
            Write-Output $CreatedVM
        }
    }
}
##TODO: Add PRTG hook to create sensors from VM