Function Invoke-ConduitMethod() {
    <#
    .SYNOPSIS
        Invoke-ConduitMethod runs a API call agains the given Phabricator instance.

    .DESCRIPTION
        Use the Invoke-ConduiMethod Cmdlet to interact with a given Phabricator instance. Therefore you can choose
        any known conduit method listed in https://secure.phabricator.com/conduit/.
        After you set up Ponduit you can choose from a prefetched method list.

    .PARAMETER Method
        The Method parameter definces the action to run against the phabricator instance. The parameter itself is
        implemented as a dynamic parameter. This enables you to read a list of all known methods.

    .PARAMETER Body
        You need to provide the body parameter as a hashtables. The hashtable has to contain the required keys from
        the selected method. Again, you can find a list of required keys at https://secure.phabricator.com/conduit/.

    .INPUTS
        [None]

    .OUTPUTS
        [Phabricator.Conduit.Response]

    .EXAMPLE
        .\Invoke-ConduitMethod -Method 'user.whoami' -Body @{}

    .EXAMPLE
        .\Invoke-ConduitMethod -Methid 'phriction.info' -Body @{slug = '/changelog'}

    .NOTES
        File Name   : Invoke-ConduitMethod.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/Ponduit
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
        # lets first bind the dynamic param to easy to use var
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
