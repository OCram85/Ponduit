Function Get-ConduitConfigPath() {
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
        File Name   : Get-ConduitConfigPath.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    : <ModuleNames>

    .LINK
        https://github.com/OCram85/PhabricatorAPI
    #>
    [CmdletBinding()]
    Param()

    Switch (Get-OS) {
        'Windows_NT' {
            "{0}\ConduitConfig.json" -f $env:APPDATA
        }

        'Linux' {
            "{0}/ConduitConfig.json" -f $Env:HOME
        }

        'OSX' {
            Write-Error 'Not implemented yet for OSX systems!' -ErrorAction Stop
        }
    }
}