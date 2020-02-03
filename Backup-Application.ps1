################################################################################
#.SYNOPSIS
# Backs up an application directory and cleans up old copies
#
#.DESCRIPTION
# Backup an application directory by creating a zip archive appended with the
# current date and time and moving it to a specified backup folder.
# Checks the specified backup folder and only keeps the latest 2 copies older than 2 weeks.

# .PARAMETER sourceDirectoryPath
# The path of the directory that you want to backup

# .PARAMETER backupDirectoryPath
# The path of the backup folder

# .PARAMETER applicationName
# The name of the application that you want to back up. This correlates to the folder name of the application.

# .EXAMPLE (No spaces in directory names)
# PS D:\Temp\Backup> .\Backup-Application "D:\EntityCentralWwwRoot\EntityCentral" "D:\Temp\Backups" "EntityCentral"

# .EXAMPLE (Spaces in directory names)
# PS D:\Temp\Backup> .\Backup-Application "D:\Entity Central WwwRoot\Entity Central" "D:\Temp\Backup Directory" "Entity Central"
################################################################################

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string] $sourceDirectoryPath,

    [Parameter(Mandatory = $true)]
    [string] $backupDirectoryPath,

    [Parameter(Mandatory = $true)]
    [string] $applicationName
)

# Strip out whitespaces for applicaiton name if any.
$applicationName = $applicationName.Replace(" ", "")

# Exit program when source directory doesn't exist
if (-Not (Test-Path -Path $sourceDirectoryPath)) {
    Write-Output("Source directory {0} does not exist, exiting..." -f $sourceDirectoryPath)
    exit
}

# Create backup directory when it doesn't exist
if (-Not (Test-Path -Path $backupDirectoryPath)) {
    Write-Output("Backup directory {0} does not exist, creating..." -f $backupDirectoryPath)

    New-Item -Path $backupDirectoryPath -ItemType directory | Out-Null
}

#### Debug ####
Write-Debug ("Source Directory Path = {0}" -f $sourceDirectoryPath)
Write-Debug ("Destination Directory Path = {0}" -f $backupDirectoryPath)
Write-Debug ("Application Name = {0}" -f $applicationName)
#### Debug ####

$currentDate = Get-Date -UFormat %Y%m%d-%H%M # e.g. 20190311-0939
$root = $backupDirectoryPath + "\"
$destinationFileName = $root + $applicationName + "-" + $currentDate + ".zip"

#### Debug ####
Write-Debug ("Current Date = {0}" -f $currentDate)
Write-Debug ("Destination Directory with trailing slash = {0}" -f $root)
Write-Debug ("Destination Filename = {0}" -f $destinationFileName)
#### Debug ####

Write-Verbose("Starting the backup process...")
If (Test-Path $destinationFilename) {
    Write-Verbose ("Destination file '{0}' already exists, deleting..." -f $destinationFileName)
    Remove-item $destinationFilename
}

Write-Output ("Beginning backup process...")

Write-Output ("Compressing files from '{0}' and moving to '{1}'..." -f $sourceDirectoryPath, $backupDirectoryPath)

Add-Type -AssemblyName "system.io.compression.filesystem"

Write-Verbose ("Creating zip file from '{0}' and saving it to '{1}'" -f $sourceDirectoryPath, $destinationFilename)

[io.compression.zipfile]::CreateFromDirectory($sourceDirectoryPath, $destinationFilename)

Write-Verbose ("Getting list of current backup files for '{0}' from '{1}' older than 2 weeks..." -f $applicationName, $backupDirectoryPath)

$cutoffDate = (Get-Date).AddDays(-14);
$backupFiles = Get-ChildItem $root | Where-Object { $_.Name -match $applicationName + "-" -and $_.LastWriteTime.Date -le $cutoffDate.Date } | Sort-Object -Property LastWriteTime

$count = ($backupFiles | Measure-Object).Count

Write-Verbose ("{0} backup file(s) exists in '{1}' older than 2 weeks:" -f $count, $backupDirectoryPath)

foreach ($file in $backupFiles) {
    Write-Verbose ($file)
}

Write-Output("Cleaning up backup files older than 2 weeks from '{0}'..." -f $backupDirectoryPath)

If ($count -gt 2) {
    Write-Output ("There are more than 2 backup files older than 2 weeks, cleaning up to only keep the latest 2...")
    $currentCount = $count
    $files = $backupFiles

    while ($currentCount -gt 2) {
        $firstIndex = 0
        $nextIndex = 1

        $modifiedDateOfFirstFile = [datetime]$files[$firstIndex].LastWriteTime
        $modifiedDateOfNextFile = [datetime]$files[$nextIndex].LastWriteTime

        Write-Verbose ("Checking to see if the modified date of '{0} ({1})' is equal to or before {2} ({3})" -f $files[$firstIndex], $modifiedDateOfFirstFile, $files[$nextIndex], $modifiedDateOfNextFile)

        If ($modifiedDateOfFirstFile -le $modifiedDateOfNextFile) {
            $filePath = $root + $files[$firstIndex]

            Write-Verbose ("The modified date is equal to or before, deleting {0}" -f $files[$firstIndex])

            Remove-Item $filePath
        }

        # Get the list of files again and update the current count
        $files = Get-ChildItem $root | Where-Object { $_.Name -match $applicationName + "-" -and $_.LastWriteTime -le $cutoffDate } | Sort-Object -Property LastWriteTime
        $currentCount = ($files | Measure-Object).Count

        Write-Verbose ("There are currently {0} backup files older than 2 weeks:" -f $currentCount)

        foreach ($file in $files) {
            Write-Verbose ($file)
        }
    }
    Write-Output ("Backup complete!")
}
Else {
    Write-Output ("There are not more than 2 backup files older than 2 weeks!")
    Write-Output ("Backup complete!")
}