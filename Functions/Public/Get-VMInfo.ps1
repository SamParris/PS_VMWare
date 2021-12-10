<#
.SYNOPSIS
    Gets all current VMs within the connected vCenter.
.DESCRIPTION

.NOTES
    AUTHOR: Sam Parris
    CREATION DATE: 07-December-2021
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
param()

Function VMWare.Get-VMInfo {
    [CmdletBinding()]
    Param(
        [Switch] $PoweredOn,
        [Switch] $PoweredOff
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
        If ($PoweredOn.IsPresent) {
            If ($PoweredOff.IsPresent) {
                Write-Error "[X] You can only specify one Power State parameter (-PoweredOn or -PoweredOff)"
            }
            Else {
                Try {
                    Write-Host "[-] Retrieving VM Information" -ForegroundColor Cyan
                    $CollectedVMs = Get-VM | Where-Object { $_.PowerState -eq 'PoweredOn' }
                }
                Catch {
                    Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
                }
                If (-Not($CollectedVMs)) {
                    Write-Error "[X] No PoweredOn VMs found."
                }
                Else {
                    Write-Host "[+] PoweredOn VMs Found: $($CollectedVMs.Count)" -ForegroundColor Green
                    $VMInfoArray = @()

                    ForEach ($VM in $CollectedVMs) {
                        $VMGuest = Get-VMGuest -VM $VM.Name
                        $VMDisk = Get-VMGuestDisk -VM $VM.Name
                        $VMObject = [PSCustomObject]@{
                            Name        = $VM.Name
                            vCPU        = $VM.NumCPU
                            MemoryGB    = $VM.MemoryGB
                            CapacityGB  = [Math]::Round($VMDisk.CapacityGB, 2)
                            FreeSpaceGB = [Math]::Round($VMDisk.FreeSpaceGB, 2)
                            VMWareTools = $VMGuest.ToolsVersion
                        }
                        $VMInfoArray += $VMObject
                    }
                    $VMInfoArray | Sort-Object Name | Format-Table
                }
            }
        }
        ElseIf ($PoweredOff.IsPresent) {
            If ($PoweredOn.IsPresent) {
                Write-Error "[X] You can only specify one Power State parameter (-PoweredOn or -PoweredOff)"
            }
            Else {
                Try {
                    Write-Host "[-] Retrieving VM Information" -ForegroundColor Cyan
                    $CollectedVMs = Get-VM | Where-Object { $_.PowerState -eq 'PoweredOff' }
                }
                Catch {
                    Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
                }
                If (-Not($CollectedVMs)) {
                    Write-Error "[X] No PoweredOff VMs found."
                }
                Else {
                    Write-Host "[+] PoweredOff VMs Found: $($CollectedVMs.Count)" -ForegroundColor Green
                    $VMInfoArray = @()

                    ForEach ($VM in $CollectedVMs) {
                        $VMGuest = Get-VMGuest -VM $VM.Name
                        $VMDisk = Get-VMGuestDisk -VM $VM.Name
                        $VMObject = [PSCustomObject]@{
                            Name        = $VM.Name
                            vCPU        = $VM.NumCPU
                            MemoryGB    = $VM.MemoryGB
                            CapacityGB  = [Math]::Round($VMDisk.CapacityGB, 2)
                            FreeSpaceGB = [Math]::Round($VMDisk.FreeSpaceGB, 2)
                            VMWareTools = $VMGuest.ToolsVersion
                        }
                        $VMInfoArray += $VMObject
                    }
                    $VMInfoArray | Sort-Object Name | Format-Table
                }
            }
        }
        Else {
            Try {
                Write-Host "[-] Retrieving VM Information" -ForegroundColor Cyan
                $CollectedVMs = Get-VM
            }
            Catch {
                Write-Error "[X] $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)."
            }
            If (-Not($CollectedVMs)) {
                Write-Error "[X] No VMs found."
            }
            Else {
                Write-Host "[+] VMs Found: $($CollectedVMs.Count)" -ForegroundColor Green
                Write-Host "[*] PoweredOn: $(($CollectedVMs | Where-Object {$_.PowerState -eq 'PoweredOn'}).Count)" -ForegroundColor Magenta
                Write-Host "[*] PoweredOff: $(($CollectedVMs | Where-Object {$_.PowerState -eq 'PoweredOff'}).Count)" -ForegroundColor Magenta
                $VMInfoArray = @()

                ForEach ($VM in $CollectedVMs) {
                    $VMGuest = Get-VMGuest -VM $VM.Name
                    $VMDisk = Get-VMGuestDisk -VM $VM.Name
                    $VMObject = [PSCustomObject]@{
                        Name        = $VM.Name
                        PowerState  = $VM.PowerState
                        vCPU        = $VM.NumCPU
                        MemoryGB    = $VM.MemoryGB
                        CapacityGB  = [Math]::Round($VMDisk.CapacityGB, 2)
                        FreeSpaceGB = [Math]::Round($VMDisk.FreeSpaceGB, 2)
                        VMWareTools = $VMGuest.ToolsVersion
                    }
                    $VMInfoArray += $VMObject
                }
                $VMInfoArray | Sort-Object Name | Format-Table
            }
        }
    }
}