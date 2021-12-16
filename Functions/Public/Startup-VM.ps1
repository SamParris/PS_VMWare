#Region VMWare.Startup-VM

<#
.SYNOPSIS
    Startsup VM Specified.
.DESCRIPTION
    This will startup the VMWare VM or all powered off VMs if required.
.PARAMETER VMName
    Specify the VM or VMs required to be started up using this function.
.PARAMETER CompleteStartup
    If this switch is specified, this function will collect all currently powered off VMs within the VMWare ESXi.
    Each VM will be started up using this function.
.EXAMPLE
    VMWare.VMWare.Startup-VM -VMName MY_VM_NAME

    Description
    -----------
    This function starts up the VM with the name provided.
.EXAMPLE
    VMWare.Startup-VM -CompleteStartup

    Description
    -----------
    This function will collect all currently powered off VMs within the VMWare ESXi and start up each one.
.NOTES
    AUTHOR: Sam Parris
    CREATION DATE: 16-December-2021
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
param()

Function VMWare.Startup-VM {
    [CmdletBinding()]
    Param(
        [Parameter()] $VMName,
        [Switch] $CompleteStartup
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        If ($DefaultVIServer) {
            Write-Host "[+] Connected to $($DefaultVIServer.Name) as $($DefaultVIServer.User)" -ForegroundColor Green
        }
        Else {
            Write-Error "[X] You must be connected to a VIServer to run this function."
        }
    }
    Process {
        If ($PSBoundParameters.ContainsKey('VMName')) {
            ForEach ($VM in $VMName) {
                Write-Host "[-] Starting Up VM: $VM" -ForegroundColor Cyan -NoNewline
                Try {
                    Start-VM -VM $VM -Confirm:$false | Out-Null
                }
                Catch {
                    Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
                }
                Write-Host " Complete" -ForegroundColor DarkGray
                Write-Host "[+] $VM has been started" -ForegroundColor Green
            }
        }
        ElseIf ($CompleteShutdown.IsPresent) {
            Try {
                Write-Host "[-] Retrieving VM Information" -ForegroundColor Cyan
                $PoweredOffVM = Get-VM | Where-Object { $_.PowerState -eq 'PoweredOff' }
            }
            Catch {
                Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
            }
            If (-Not($PoweredOffVM)) {
                Write-Error "[X] No PoweredOff VMs Found."
            }
            Else {
                Write-Host "[+] PoweredOff VMs Found: $($PoweredOffVM.Count)" -ForegroundColor Green
                Write-Output $PoweredOffVM

                $Yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes'
                $No = New-Object System.Management.Automation.Host.ChoiceDescription '&No'

                $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)

                $Title = "Complete Startup"
                $Message = "Are you sure you want to start up all $($PoweredOffVM.Count) VMs?"
                $Result = $host.ui.PromptForChoice($Title, $Message, $Options, 0)

                If ($Result -eq 0) {
                    ForEach ($VM in $PoweredOffVM) {
                        Write-Host "[-] Starting Up VM: $VM" -ForegroundColor Cyan -NoNewline
                        Try {
                            Start-VM -VM $VM -Confirm:$false | Out-Null
                        }
                        Catch {
                            Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
                        }
                        Write-Host " Complete" -ForegroundColor DarkGray
                    }
                    Write-Host "[+] All $($PoweredOffVM.Count) VMs have been started" -ForegroundColor Green
                }
                Else {
                    Write-Host "[+] Function has been cancelled" -ForegroundColor Green
                }
            }
        }
    }
}

#EndRegion VMWare.Shutdown-VM