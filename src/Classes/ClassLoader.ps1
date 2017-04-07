If ($PSVersionTable.PSVersion.Major -ge 5) {
    Write-Verbose "ClassLoader: Importing Classes..."
    $ClassPath = Join-Path -Path $PSScriptRoot -ChildPath "*.ps1"
    $Items = Get-ChildItem -Path $ClassPath -Recurse -Exclude 'ClassLoader.ps1'
    ForEach ($Item in $Items) {
        Write-Verbose $Item.BaseName
        . $Item.Fullname
    }
}
