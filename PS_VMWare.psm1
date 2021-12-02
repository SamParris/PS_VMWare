<#
.SYNOPSIS
    Dot source all functions in all *.PS1 files in the module folder.
.DESCRIPTION
    This will dot source through all the files in the PS_VMWare module folder, making them available to use.
.NOTES
    AUTHOR: Sam Parris
    CREATION DATE: 02-December-2021
#>

$PublicFunctionFiles = [System.IO.Path]::Combine($PSScriptRoot,"Functions","Public","*.ps1")

Get-ChildItem -Path $PublicFunctionFiles |
    ForEach-Object {
        Try {
            . $_.FullName
        } Catch {
            Write-Warning "$($_.Exception.Message)"
        }
    }