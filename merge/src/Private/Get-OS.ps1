 # This Wrapper is needed to mock the PSVersionTable with Pester
 Function Get-PSVersion() {
     [CmdletBinding()]
     [OutputType('System.Version')]
     Param()
     Return $PSVersionTable.PSVersion
 }
Function Get-OS() {
    <#
            .SYNOPSIS
            Get-OS returns the current running OS Type.

            .DESCRIPTION
            Get-OS tries to deteminate the curren OS Type by some known prexisting enviroment variables.

            .INPUTS
            [None]

            .OUTPUTS
            [String]

            .EXAMPLE
            Get-OS

            .NOTES
            File Name   : Get-OS.ps1
            Author      : Marco Blessing - marco.blessing@googlemail.com
            Requires    :

            .LINK
            https://github.com/OCram85/PhabricatorAPI
    #>
    [CmdletBinding()]
    Param()
    
    $PSVersion = Get-PSVersion
    If ($PSVersion.Major -le 5) {
        $Env:OS
    }
    Else {
        If ($IsWindows) {
            $Env:OS
        }
        If ($IsLinux) {
            Return "Linux"
        }
        If ($IsOSX) {
            Return "OSX"
        }
    }
}