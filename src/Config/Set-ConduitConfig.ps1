Function Set-ConduitConfig() {
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
        File Name   : SetConduitConfig.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    : <ModuleNames>

    .LINK
        https://github.com/OCram85/PhabricatorAPI
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateSet('conduit-token', 'phabricator-uri')]
        [String]$Key,

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [String]$Value
    )

    $Config = Get-ConduitConfig -Raw

    Switch ($Key) {
        'conduit-token' {
            $Config.'conduit-token' = $Value
        }
        'phabricator-uri' {
            $Config.'phabricator-uri' = $Value
        }
    }

    $Config | ConvertTo-Json | Out-File -FilePath $ConfigDir -Encoding utf8 -Force
}
