Function Get-ConduitConfig() {
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
            File Name   : Get-ConduitConfig.ps1
            Author      : Marco Blessing - marco.blessing@googlemail.com
            Requires    : <ModuleNames>

            .LINK
            https://github.com/OCram85/PhabricatorAPI
    #>
    [CmdletBinding(DefaultParameterSetName="Simple")]
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
        }
    }
    End {
        $Config.psobject.TypeNames.Insert(0,'PhabricatorAPI.Conduit.Config')
        Return $Config
    }
}