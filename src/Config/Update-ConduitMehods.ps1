Function Update-ConduitMethods() {
    <#
    .SYNOPSIS
        Update-ConduitMethods updates all known conduitmehtods to a local cache like list.

    .DESCRIPTION
        This function is a helper for Invoke-ConduitMethod. It updates a local cache list to validate the method
        param from Invoke-ConduitMethod.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        Update-ConduitMethods

    .NOTES
        File Name   : Update-ConduitMethods.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

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