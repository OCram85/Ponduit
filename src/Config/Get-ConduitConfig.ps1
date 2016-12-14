Function Get-ConduitConfig() {
    <#
            .SYNOPSIS
            Get-ConduitConfig returns saved config values.

            .DESCRIPTION
            This function is a helper for other top level functions. You can use it to validate your
            saved configuration.

            .PARAMETER Key
            Specify the config key you would like to read.

            .PARAMETER Raw
            This Switch enables you to get the complete config.

            .INPUTS
            [None]

            .OUTPUTS
            [PSCustomObject]

            .EXAMPLE
            Get-ConduitConfig -Raw

            .EXAMPLE
            $Foo = Get-ConduitConfig -Key 'conduit-token'

            .NOTES
            File Name   : Get-ConduitConfig.ps1
            Author      : Marco Blessing - marco.blessing@googlemail.com
            Requires    :

            .LINK
            https://github.com/OCram85/PhabricatorAPI

    #>
    [CmdletBinding(DefaultParameterSetName="Simple")]
    [OutputType([PSCustomObject])]
    Param(
        [Parameter(Mandatory = $True, ParameterSetName = 'Simple')]
        [ValidateSet('conduit-token', 'phabricator-uri')]
        [String]$Key,

        [Parameter(Mandatory=$False, ParameterSetName = 'Raw')]
        [Switch]$Raw
    )

    Begin {
        $ConfigDir = Get-ConduitConfigPath
    }

    Process {
        If (Test-Path -Path $ConfigDir) {
            Try {
                $Config = Get-Content $ConfigDir -Raw | ConvertFrom-Json
            }
            Catch {
                Write-Error -Message "Could not read the existing config file!" -ErrorAction Stop
            }
            If ($PSCmdlet.ParameterSetName -eq 'Simple') {
                $Config = $Config.$Key
            }
        }
    }
    End {
        If ($PSCmdlet.ParameterSetName -eq 'Raw' ) {
            $Config.psobject.TypeNames.Insert(0,'PhabricatorAPI.Conduit.Config')
        }
        Else {
            $Config = [PSCustomObject]@{
                Key = $Key
                Value = $Config
            }
            $Config.psobject.TypeNames.Insert(0,'PhabricatorAPI.Conduit.Config.Item')
            Update-TypeData -TypeName "PhabricatorAPI.Conduit.Config.Item" -DefaultDisplayProperty 'Value' -DefaultDisplayPropertySet 'Value'
        }
        Return $Config
    }
}