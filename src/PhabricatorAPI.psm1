$Items = (Get-ChildItem -Path ("{0}\*.ps1" -f $PSScriptRoot ) -Recurse ).FullName | Where-Object {
    $_ -notmatch "(Classes|Invoke-DotSourcing.ps1)"
}
ForEach ($Item in $Items) {
    # Write-Verbose ("Dotsourcing file {0}" -f $Item)
    . $Item
}

Export-ModuleMember -Function *
