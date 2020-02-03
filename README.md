# Backup Application

## Summary

Performs a backup of a directory containing application files by creating a zip archive appended with the current date and time, and moving it to a specified backup directory location. Checks the specified backup directory location and only keeps the latest 2 files older than 2 weeks.

## Requirements

- Powershell, Version 5.1.14409.1018 or higher.
- Pester, Version 4.9.0 or higher (to run unit tests)

## Notes

This script can be run in three different ways:

Provide the arguments exclusively

```powershell
.\Backup-Application -sourceDirectoryPath "D:\WwwRoot\ApplicationName" -backupDirectoryPath "D:\Backups" -applicationName "ApplicationName"
```

Providing the arguments in the correct order

```powershell
.\Backup-Application "D:\WwwRoot\ApplicationName" "D:\Backups" "ApplicationName"
```

Providing the script name and then entering the arguments at the command prompt

```powershell
.\Backup-Application
sourceDirectoryPath:
```

## Usage/Examples

Backup a directory that contains no spaces

```powershell
PS > .\Backup-Application -sourceDirectoryPath "D:\WwwRoot\MyAwesomeApplication" -backupDirectoryPath "D:\Temp\Backups" -applicationName "MyAwesomeApplication"
```

Backup a directory that contains spaces

```powershell
PS > .\Backup-Application -sourceDirectoryPath "D:\WwwRoot\My Awesome Application" -backupDirectoryPath "D:\Temp\Backups" -applicationName "My Awesome Application"
```

## Unit Tests

There are tests created with Pester than can be run to verify the script functionality. The tests are configured to run with Pester version 4.9.0. To check your Pester version, run the following command in PowerShell

```powershell
Get-Module -Name "Pester"
```

If you are running a lower version, follow the installation steps here [https://pester.dev/docs/introduction/installation](https://pester.dev/docs/introduction/installation)

To run the tests, open PowerShell, navigate to the project root folder and run the following commands

```powershell
cd Tests
.\Run-Tests.ps1
```
