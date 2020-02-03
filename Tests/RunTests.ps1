$testDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Invoke-Pester -Script @{ Path = $testDir + "\Backup-Application.Tests.ps1" }
