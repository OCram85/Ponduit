Function Invoke-AppVeyorBumpVersion() {
    [CmdletBinding()]
    Param()
    $ModManifest = Get-Content -Path '.\src\Ponduit.psd1'
    $BumpedManifest = $ModManifest -replace '$Env:APPVEYOR_BUILD_VERSION', "'$Env:APPVEYOR_BUILD_VERSION'"
    Out-File -FilePath '.\src\Ponduit.psd1' -InputObject $BumpedManifest -NoClobber -Encoding utf8 -Force
}

Function Invoke-AppVeyorBuild() {
    [CmdletBinding()]
    Param()
    $MsgParams = @{
        Message = 'Creating build artifacts'
        Category = 'Information'
        Details = 'Extracting srouce files and compressing them into zip file.'
    }
    Add-AppveyorMessage @MsgParams
    #7z a Ponduit.zip ("{0}\src\*" -f $env:APPVEYOR_BUILD_FOLDER)
    $CompParams = @{
        Path = "{0}\src\*" -f $env:APPVEYOR_BUILD_FOLDER
        DestinationPath = "{0}\bin\Ponduit.zip" -f $env:APPVEYOR_BUILD_FOLDER
        Update = $True
        Verbose = $True
    }
    Compress-Archive @CompParams
    $MsgParams = @{
        Message = 'Pushing artifacts'
        Category = 'Information'
        Details = 'Pushing artifacts to AppVeyor store.'
    }
    Add-AppveyorMessage @MsgParams
    Push-AppveyorArtifact ".\bin\Ponduit.zip"
}

Function Invoke-AppVeyorTests() {
    [CmdletBinding()]
    Param()

    $testResultsFile = ".\TestsResults.xml"
    If (Test-Path -Path $testResultsFile) {
        Remove-Item -Path $testResultsFile -Force
        $MsgParams = @{
            Message = 'Old Pester Restults removed'
            Category = 'Information'
            Details = 'Unknown result file found. Removed it.'
        }
        Add-AppveyorMessage @MsgParams
    }

    $MsgParams = @{
            Message = 'Starting Pester tests'
            Category = 'Information'
            Details = 'Now running all test found in .\tests\ dir.'
        }
    Add-AppveyorMessage @MsgParams
    $res = Invoke-Pester -Path ".\tests\*" -OutputFormat NUnitXml -OutputFile $testResultsFile -PassThru
    $MsgParams = @{
            Message = 'Uploading Pester Results'
            Category = 'Information'
            Details = 'Pester Tests finished. Uploading result file.'
        }
    Add-AppveyorMessage @MsgParams
    (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path $testResultsFile))
    If ($res.FailedCount -gt 0) {
        $MsgParams = @{
            Message = 'Pester Tests failed.'
            Category = 'Error'
            Details = "$($res.FailedCount) tests failed."
        }
        Add-AppveyorMessage @MsgParams
        Throw "$($res.FailedCount) tests failed."
    }

}

function Invoke-AppVeyorPSGallery() {
    [CmdletBinding()]
    Param()
    If ($env:APPVEYOR_REPO_BRANCH -eq 'master') {
        Expand-Archive -Path '.\bin\Ponduit.zip' -DestinationPath 'C:\Users\appveyor\Documents\WindowsPowerShell\Modules\Ponduit\' -Verbose
        Import-Module -Name 'Ponduit' -Verbose -Force
        Write-Host "try to publish module" -ForegroundColor Red -BackgroundColor Black
        Publish-Module -Name 'Ponduit' -NuGetApiKey $env:NuGetToken -Verbose -Force
    }
}
