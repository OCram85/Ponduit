[![AppVeyor branch](https://img.shields.io/appveyor/ci/OCram85/Ponduit/master.svg?style=plastic "Master Banch Build Status")](https://ci.appveyor.com/project/OCram85/ponduit/branch/master)
[![AppVeyor tests branch](https://img.shields.io/appveyor/tests/OCram85/Ponduit/master.svg?style=plastic "Pester Tests Results")](https://ci.appveyor.com/project/OCram85/ponduit/branch/master/tests)
[![Coveralls github](https://img.shields.io/coveralls/github/OCram85/Ponduit.svg?style=plastic "Coveralls.io Coverage Report")](https://coveralls.io/github/OCram85/Ponduitbranch=master)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/Ponduit.svg?style=plastic "PowershellGallery Published Version")](https://www.powershellgallery.com/packages/Ponduit)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/Ponduit.svg?style=plastic "PowershellGallery Downloads")](https://www.powershellgallery.com/packages/Ponduit)

![forthebadge](http://forthebadge.com/images/badges/built-with-love.svg)
![forthebadge](http://forthebadge.com/images/badges/for-you.svg)

General
=======

Ponduit is a simple Powershell based [Phabricator](https://phacility.com/) Conduit Client.
It enables you to interact with all known [Conduit Methods](https://secure.phabricator.com/conduit/).

To get started read the [about_Ponduit](/src/en-US/about_Ponduit.help.txt) page.

Installation
============


PowerShellGallery.com (Recommended Way)
---------------------------------------

* Make sure you use PowerShell 5.0 or higher with `$PSVersionTable`.
* Use the builtin PackageManagement and install with: `Install-Module Ponduit`
* Done. Start exploring the Module with `Import-Module Ponduit ; Get-Command -Module Ponduit`

Manual Way
----------

* Take a look at the [Latest Release](https://github.com/OCram85/Ponduit/releases/latest) page.
* Download the `Ponduit.zip`.
* Unpack the Zip and put it in your Powershell Module path.
  * Don't forget to change the NTFS permission flag in the context menu.
* Start with `Import-Module Ponduit`
