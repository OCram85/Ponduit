Function Update-ConduitMethods() {
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
        File Name   : Update-ConduitMethods.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    : <ModuleNames>

    .LINK
        https://github.com/OCram85/PhabricatorAPI
    #>
    [CmdletBinding()]
    Param()

    $Config = Get-ConduitConfig -Raw
    $APIParams = @{
        'api.token' = $Config.'conduit-token'

    }
    $ConduitURI = "{0}/api/conduit.query" -f $Config.'phabricator-uri'
    $APIResult = Invoke-RestMethod -Method Post -Uri $ConduitUri -Body $APIParams
    $Properties = $APIResult.result | Get-Member
    #$Methods = $APIResult.result
    $Methods = $Properties | Where-Object { $_.MemberType -eq "NoteProperty"} | Select-Object -ExpandProperty Name
    $Config = Get-ConduitConfig -Raw
    $Config.'conduit-methods' = $Methods
    $ConfigDir = Get-ConduitConfigPath
    $Config | ConvertTo-Json | Out-File -FilePath $ConfigDir -Encoding utf8 -Force
}