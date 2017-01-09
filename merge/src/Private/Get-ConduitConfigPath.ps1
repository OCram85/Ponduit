Function Get-ConduitConfigPath() {
    <#
    .SYNOPSIS
        Returns a valid path for the conduit config file.

    .DESCRIPTION
        Depending on the current OS this returns a valid path for the conduit config file.

    .INPUTS
        [None]

    .OUTPUTS
        [String]

    .EXAMPLE
        $Path = Get-ConduitConfigPath
        If (Test-Path -Path $Path) {
            Get-ConduitConfig -Raw
        }

    .NOTES
        File Name   : Get-ConduitConfigPath.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

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
