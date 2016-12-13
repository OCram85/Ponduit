Function Get-OS() {
    <#
    .SYNOPSIS
        A brief description of the function or script.

    .DESCRIPTION
        Describe the function of the script using a single sentence or more.

    .PARAMETER One
        Description of the Parameter (what it does)

    .INPUTS
        Describe the script input parameters (if any), otherwise it may also list the word "[None]".

    .OUTPUTS
        Describe the script output parameters (if any), otherwise it may also list the word "[None]".

    .EXAMPLE
        .\Remove-Some-Script.ps1 -One content

    .NOTES
        File Name   : Get-OS.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    : <ModuleNames>

    .LINK
        https://github.com/OCram85/PhabricatorAPI
    #>
    [CmdletBinding()]
    Param()

    If (($PSVersionTable).PSVersion.Major -le 5) {
        $Env:OS
    }
    Else {
        If ($IsWindows) {
            $Env:OS
        }
        If ($IsLinux) {
            Return "Linux"
        }
        If ($IsOSX) {
            Return "OSX"
        }
    }
}