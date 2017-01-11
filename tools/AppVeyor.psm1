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

Function Invoke-AppVeyorBuild() {
    [CmdletBinding()]
    Param()
    $MsgParams = @{
        Message = 'Creating build artifacts'
        Category = 'Information'
        Details = 'Extracting srouce files and compressing them into zip file.'
    }
    Add-AppveyorMessage @MsgParams
    7z a Ponduit.zip ("{0}\src\*" -f $env:APPVEYOR_BUILD_FOLDER)
    $MsgParams = @{
        Message = 'Pushing artifacts'
        Category = 'Information'
        Details = 'Pushing artifacts to AppVeyor store.'
    }
    Add-AppveyorMessage @MsgParams
    Push-AppveyorArtifact Ponduit.zip
}

Function Invoke-AppVeyorPSGallery() {
    [CmdletBinding()]
    Param()
    Write-Host "Publish Module on PowershellGallery."
    Try {
        $PubParams = @{
            Path = "C:\projects\ponduit\src\Ponduit.psd1"
            NuGetApiKey = $env:NuGetToken
            Verbose = $True
        }
        Publish-Module @PubParams
    }
    Catch {
        $MsgParams = @{
            Message = 'Deploy to PowershellGallery failed!'
            Category = 'Error'
            Details = $_.Exception.Message
        }
        Add-AppveyorMessage @MsgParams
        Throw "$_.Exception.Message"
    }
}