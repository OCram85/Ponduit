Function Invoke-AppVeyorBumpVersion() {
    [CmdletBinding()]
    Param()

    Write-Host "Listing Env Vars for debugging:" -ForegroundColor Yellow
    Get-ChildItem Env:
    Write-Host "Getting vars for debugging:" -ForegroundColor Yellow
    Get-Variable -Name *

    Try {
        $ModManifest = Get-Content -Path '.\src\Ponduit.psd1'
        $BumpedManifest = $ModManifest -replace '\$Env:APPVEYOR_BUILD_VERSION', "'$Env:APPVEYOR_BUILD_VERSION'"
        Remove-Item -Path '.\src\Ponduit.psd1'
        Out-File -FilePath '.\src\Ponduit.psd1' -InputObject $BumpedManifest -NoClobber -Encoding utf8 -Force
    }
    Catch {
        $MsgParams = @{
            Message = 'Could not bump current version into module manifest.'
            Category = 'Error'
            Details = $_.Exception.Message
        }
        Add-AppveyorMessage @MsgParams
        Throw $MsgParams.Message
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
        Throw $MsgParams.Message
    }

}

function Invoke-AppVeyorPSGallery() {
    [CmdletBinding()]
    Param()
    Expand-Archive -Path '.\bin\Ponduit.zip' -DestinationPath 'C:\Users\appveyor\Documents\WindowsPowerShell\Modules\Ponduit\' -Verbose
    Import-Module -Name 'Ponduit' -Verbose -Force
    Write-Host "Available Package Provider:" -ForegroundColor Yellow
    Get-PackageProvider -ListAvailable
    Write-Host "Available Package Sources:" -ForegroundColor Yellow
    Get-PackageSource
    Try {
        Write-Host "Try to get NuGet Provider:" -ForegroundColor Yellow
        Get-PackageProvider -Name NuGet -ErrorAction Stop
    }
    Catch {
        Write-Host "Installing NuGet..." -ForegroundColor Yellow
        Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Force -Verbose
        Import-PackageProvider NuGet -MinimumVersion '2.8.5.201' -Force
    }
    Try {
        If ($env:APPVEYOR_REPO_BRANCH -eq 'master') {
            Write-Host "try to publish module" -ForegroundColor Yellow
            Publish-Module -Name 'Ponduit' -NuGetApiKey $env:NuGetToken -Verbose -Force
        }
        Else {
            Write-Host "Skip publishing to PS Gallery because we are on $(env:APPVEYOR_REPO_BRANCH) branch." -ForegroundColor Yellow
            # had to remve the publish-Module statement bacause it would publish although the -WhatIf is given.
            # Publish-Module -Name 'Ponduit' -NuGetApiKey $env:NuGetToken -Verbose -WhatIf
        }
    }
    Catch {
        $MsgParams = @{
            Message = 'Could not delpoy module to PSGallery.'
            Category = 'Error'
            Details = $_.Exception.Message
        }
        Add-AppveyorMessage @MsgParams
        Throw $MsgParams.Message
    }
}
