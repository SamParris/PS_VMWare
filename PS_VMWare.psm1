<#
.SYNOPSIS
    Dot source all functions in all *.PS1 files in the module folder.
.DESCRIPTION
    This will dot source through all the files in the PS_VMWare module folder, making them available to use.
.NOTES
    AUTHOR: Sam Parris
    CREATION DATE: 02-December-2021
#>

#Dot Source all .ps1 files located within the public folder in the module.
$PublicFunctionFiles = [System.IO.Path]::Combine($PSScriptRoot, "Functions", "Public", "*.ps1")

Get-ChildItem -Path $PublicFunctionFiles |
ForEach-Object {
    Try {
        . $_.FullName
    }
    Catch {
        Write-Warning "$($_.Exception.Message)"
    }
}

#Dot Source all .ps1 files located within the private folder in the module, making these available to the module but not the end user.
$PrivateFunctionFiles = [System.IO.Path]::Combine($PSScriptRoot, "Functions", "Private", "*.ps1")

Get-ChildItem -Path $PrivateFunctionFiles |
ForEach-Object {
    Try {
        . $_.FullName
    }
    Catch {
        Write-Warning "$($_.Exception.Message)"
    }
}