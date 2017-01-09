Function Invoke-ConduitMethod() {
    <#
            .SYNOPSIS
            A brief description of the function or script.

            .DESCRIPTION
            Describe the function of the script using a single sentence or more.

            .PARAMETER Method
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
    Param(
        <#DISABLED Param
                [Parameter(Mandatory=$True)]
                [ValidateScript({
                (Get-ConduitConfig -Raw).'conduit-methods' -contains $_
                })]
                [String]$Method,
        endregion #>
        [Parameter(Mandatory=$True, Position = 1)]
        [ValidateNotNull()]
        [Hashtable]$Body
    )
    DynamicParam {
        #$Config = Get-ConduitConfig
        # Set the dynamic parameters' name
        $ParameterName = 'Method'

        # Create the dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 0

        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)

        # Generate and set the ValidateSet
        $arrSet = (Get-ConduitConfig -Raw).'conduit-methods'
        #$arrSet = @("foo", "bar", "foobar" )
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)

        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }
    Begin {
        # lets first bind the dynamc param to easy to use var
        $Method = $PsBoundParameters[$ParameterName]

        $Config = Get-ConduitConfig -Raw
    }
    Process {

        $Body.'api.token' = $Config.'conduit-token'

        $ReqURI = "{0}/api/{1}" -f $Config.'phabricator-uri', $Method

        $RestResponse = Invoke-RestMethod -Method Post -Uri $ReqURI -Body $Body
    }

    End {
        $RestResponse.psobject.TypeNames.Insert(0,'Phabricator.Conduit.Response')
        Return $RestResponse
    }
}
