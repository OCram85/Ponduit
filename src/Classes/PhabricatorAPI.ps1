Enum OSType {
    Windows
    Linux
    OSX
}

Class Ponduit {
    # hidden backend properties
    hidden [OSType]$_OS
    hidden [String]$_ConduitToken
    hidden [String]$_ConduitConfigPath
    hidden [String]$_PhabricatorURI
    hidden [String[]]$_ConduitMethods

    Ponduit () {
        # Init internal properties
        $this.GetOS()
        $this.GetConduitConfigPath()
        If (Test-Path -Path $this._ConduitConfigPath) {
            $this.GetConduitConfig()
            $this.UpdateConduitMethods()
            $this.SetConduitConfig()
        }
        # Create getter / setter methods for hidden properties
        # OS
        $this | Add-Member -Name OS -MemberType ScriptProperty -Value {
            # getter
            return $this._OS
        } -SecondValue {
            # setter
            Write-Warning "This is a readonly property."
        }
        # ConduitToken
        $this | Add-Member -Name ConduitToken -MemberType ScriptProperty -Value {
            # getter
            return $this._ConduitToken
        } -SecondValue {
            # setter
            Param(
                [ValidateNotNullOrEmpty()]
                [String]$ConduitToken
            )
            $this._ConduitToken = $ConduitToken
            $this.SetConduitConfig()
        }

        # ConduitConfigPath
        $this | Add-Member -Name ConduitConfigPath -MemberType ScriptProperty -Value {
            # getter
            return $this._ConduitConfigPath
        } -SecondValue {
            # setter
            Write-Warning "This is a readonly property."
        }

        # PhabricatorURI
        $this | Add-Member -Name PhabricatorURI -MemberType ScriptProperty -Value {
            # getter
            return $this._PhabricatorURI
        } -SecondValue {
            # setter
            Param(
                [ValidateNotNullOrEmpty()]
                [String]$URI
            )
            $this._PhabricatorURI= $URI
            $this.SetConduitConfig()
        }

        # ConduitMethods
        $this | Add-Member -Name ConduitMethods -MemberType ScriptProperty -Value {
            # getter
            return $this._ConduitMethods
        } -SecondValue {
            # setter
            Write-Warning "This is a readonly property."
        }
    }

    Ponduit ([String]$ConduitToken, [String]$PhabricatorURI) {
        $this.GetOS()
        $this._ConduitToken = $ConduitToken
        $this._PhabricatorURI = $PhabricatorURI
        $this.UpdateConduitMethods()
    }

    hidden [Void]GetOS () {
        If (($Global:PSVersionTable).PSVersion.Major -le 5) {
            $this._OS = [OSType]::Windows
        }
        Else {
            If ($Global:IsWindows) {
                $this._OS = [OSType]::Windows
                }
            If ($Global:IsLinux) {
                $this._OS = [OSType]::Linux
            }
            If ($Global:IsOSX) {
                $this._OS = [OSType]::OSX
            }
        }
    }

    hidden [Void]GetConduitConfigPath () {
        Switch ($this._OS) {
            'Windows' {
                $this._ConduitConfigPath = "{0}\ConduitConfig.json" -f $env:APPDATA
            }

            'Linux' {
                $this._ConduitConfigPath = "{0}/ConduitConfig.json" -f $Env:HOME
            }

            'OSX' {
                Write-Error 'Not implemented yet for OSX systems!' -ErrorAction Stop
            }
        }
    }

    hidden [Void]GetConduitConfig () {
        If (Test-Path -Path $this._ConduitConfigPath) {
            Try {
                $Config = Get-Content $this._ConduitConfigPath -Raw | ConvertFrom-Json
                $this._ConduitToken = $Config.'conduit-token'
                $this._PhabricatorURI = $Config.'phabricator-uri'
                $this._ConduitMethods = $Config.'conduit-methods'
            }
            Catch {
                Write-Error -Message "Could not read the existing config file!" -ErrorAction Stop
            }
        }
    }

    hidden [Void]SetConduitConfig () {
        #$Config = $this.GetConduitConfig()
        $Config = @{
            'conduit-token' = $this._ConduitToken
            'phabricator-uri' = $this._PhabricatorURI
            'conduit-methods' = $this._ConduitMethods
        }
        $Config | ConvertTo-Json | Out-File -FilePath $this._ConduitConfigPath -Encoding utf8 -Force
    }

    [Void]UpdateConduitMethods () {
        $RestParams = @{
            'api.token' = $this._ConduitToken
        }
        $URI = "{0}/api/conduit.query" -f $this._PhabricatorURI
        Try {
            $APIResult = Invoke-RestMethod -Method Post -Uri $URI -Body $RestParams
            $ResultProps = $APIResult.result | Get-Member
            $Methods = $ResultProps | Where-Object { $_.MemberType -eq "NoteProperty"} | Select-Object -ExpandProperty Name
            $this._ConduitMethods = $Methods
            #$this.SetConduitConfig()
        }
        Catch {
            Write-Error "Could not update all known conduit methods!"
        }
    }

    [PSCustomObject]Invoke ([String]$Method, [Hashtable]$Properties) {
        If ($this._ConduitMethods -contains $Method) {
            $Properties.'api.token' = $this._ConduitToken
            $RequestURI = "{0}/api/{1}" -f $this._PhabricatorURI, $Method
            Try {
                $Result = Invoke-RestMethod -Method Post -Uri $RequestURI -Body $Properties
                Return [PSCustomObject]$Result
            }
            Catch {
                Write-Error "Could not invoke the API call"
                return $False
            }
        }
        Else {
            Write-Error ("the given Conduit method {0} does not exist!" -f $Method)
            return $False
        }
    }
}
