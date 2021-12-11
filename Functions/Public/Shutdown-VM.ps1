#Region VMWare.Shutdown-VM

<#
.SYNOPSIS
    Shuts down VM Specified.
.DESCRIPTION
    This will shutdown the VMWare VM or all powered on VMs if required.
.PARAMETER VMName
    Specify the VM or VMs required to be shutdown using this function.
.PARAMETER CompleteShutdown
    If this switch is specified, this function will collect all currently powered on VMs within the VMWare ESXi.
    Each VM will be shutdown using this function.
.EXAMPLE
    VMWare.Shutdown-VM -VMName MY_VM_NAME

    Description
    -----------
    This function shutsdown the VM with the name provided.
.EXAMPLE
    VMWare.Shutdown-VM -CompleteShutdown

    Description
    -----------
    This function will collect all currently powered on VMs within the VMWare ESXi and shut down each one.
.NOTES
    AUTHOR: Sam Parris
    CREATION DATE: 10-December-2021
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
param()

Function VMWare.Shutdown-VM {
    [CmdletBinding()]
    Param(
        [Parameter()] $VMName,
        [Switch] $CompleteShutdown
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
                Write-Host "[-] Shutting Down VM: $VM" -ForegroundColor Cyan -NoNewline
                Try {
                    Shutdown-VMGuest -VM $VM -Confirm:$false | Out-Null
                }
                Catch {
                    Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
                }
                Write-Host " Complete" -ForegroundColor DarkGray
            }
            Write-Host "[+] $VM has been shutdown" -ForegroundColor Green
        }
        ElseIf ($CompleteShutdown.IsPresent) {
            Try {
                Write-Host "[-] Retrieving VM Information" -ForegroundColor Cyan
                $PoweredOnVM = Get-VM | Where-Object { $_.PowerState -eq 'PoweredOn' }
            }
            Catch {
                Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
            }
            If (-Not($PoweredOnVM)) {
                Write-Error "[X] No PoweredOn VMs Found."
            }
            Else {
                Write-Host "[+] PoweredOn VMs Found: $($PoweredOnVM.Count)" -ForegroundColor Green
                Write-Output $PoweredOnVM

                $Yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes'
                $No = New-Object System.Management.Automation.Host.ChoiceDescription '&No'

                $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)

                $Title = "Complete Shutdown"
                $Message = "Are you sure you want to shutdown all $($PoweredOnVM.Count) VMs?"
                $Result = $host.ui.PromptForChoice($Title, $Message, $Options, 0)

                If ($Result -eq 0) {
                    ForEach ($VM in $PoweredOnVM) {
                        Write-Host "[-] Shutting Down VM: $VM" -ForegroundColor Cyan -NoNewline
                        Try {
                            Shutdown-VMGuest -VM $VM -Confirm:$false | Out-Null
                        }
                        Catch {
                            Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
                        }
                        Write-Host " Complete" -ForegroundColor DarkGray
                    }
                    Write-Host "[+] All $($PoweredOnVM.Count) VMs have been shutdown" -ForegroundColor Green
                }
                Else {
                    Write-Host "[+] Function has been cancelled" -ForegroundColor Green
                }
            }
        }
    }
}

#EndRegion VMWare.Shutdown-VM