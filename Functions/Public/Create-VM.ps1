#Region VMWare.Create-VM

<#
.SYNOPSIS
    Creates a new VM on an ESXi Host.
.DESCRIPTION
    This function will create a new VM on the connected VMWare ESXi Host.
    Unless specified using the parameters the VM will have the following specs;
        - 4GB Memory
        - 2vCPUs
        - All Cores in a single socket

    You can have the VM auto Power On and if the VMWare Remote Tool is installed Auto Connect.
.PARAMETER NewVMName
    Mandatory Parameter - New VM Name.
.PARAMETER MemoryGB
    Default 4GB - Required amount of memory for VM.
.PARAMETER NumCPU
    Default 2 - Required vCPUs
.PARAMETER CoresPerSocket
    Default matching $NumCPU Parameter - Specified number of cores per CPU Socket.
.PARAMETER PowerOn
    If specified the VM will turn on automatically after being created.
.PARAMETER Connect
    If specified alon with the -PowerOn parameter, the VM will attempt to use the VMWare Remote Tools to connect to the new VM.
.EXAMPLE
    VMWare.VMWare.Create-VM -NewVMName 'MY_NEW_VM'

    Description
    -----------
    This function will create a default VM on the connected ESXi host with the name 'MY_NEW_VM' and the default parameters.
.NOTES
    AUTHOR: Sam Parris
    CREATION DATE: 10-December-2021
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

#EndRegion VMWare.Create-VM