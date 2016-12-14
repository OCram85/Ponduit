Function Set-ConduitConfig() {
    <#
    .SYNOPSIS
        Set-ConduitConfig stores your configuration.

    .DESCRIPTION
        This function is needet to take care of your config. You need to specify the config key you would like to
        change, followed by the desired value

    .PARAMETER Key
        Specify the config key you would like to change.

    .PARAMETER Value
        This value will be stored in the corresponding config key.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        Set-ConduitConfig -Key 'conduit-token' -Value "api-1234556780abcd"

    .EXAMPLE
        Set-ConduitConfig -Key 'pahbricator-uri -Value 'https://secure.phabricator.com'

    .NOTES
        File Name   : SetConduitConfig.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

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
