$testDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path ($testDir) -Parent

$sourceDir = $testDir + "\TestDirectories\Application"
$backupDir = $testDir + "\TestDirectories\Backup"
$appName = 'Application'

Describe 'Backup Application Directory' {
    BeforeAll {
        # Run script
        $script = $rootDir + "\Backup-Application.ps1"
        & $script -sourceDirectoryPath $sourceDir -backupDirectoryPath $backupDir -applicationName $appName
    }

    AfterAll {
        # Delete all the zip files
        Start-Sleep -s 1.5

        $filesToDelete = $backupDir + "\*.zip"
        Remove-Item $filesToDelete
    }

    It 'creates a zip file with application name, date, and time' {
        $currentDate = Get-Date -UFormat %Y%m%d-%H%M
        $expectedFile = $backupDir + "\$appName" + "-" + $currentDate + ".zip"

        Test-Path $expectedFile | Should -Be $true
    }
}

Describe "Backup File Deletion" {

    Context "when all backup files are less than 2 weeks old" {
        BeforeEach {
            $currentDate = Get-Date

            $backupFile1 = New-Item -Path $backupDir -ItemType "file" -Name "$appName-00000000-0000.zip" -Force
            $backupFile1.LastWriteTime = $currentDate.AddDays(-1)

            $backupFile2 = New-Item -Path $backupDir -ItemType "file" -Name "$appName-11111111-1111.zip" -Force
            $backupFile2.LastWriteTime = $currentDate.AddDays(-2);

            $backupFile3 = New-Item -Path $backupDir -ItemType "file" -Name "$appName-22222222-2222.zip" -Force
            $backupFile3.LastWriteTime = $currentDate.AddDays(-3);

            # Run script
            $script = $rootDir + "\Backup-Application.ps1"
            & $script -sourceDirectoryPath $sourceDir -backupDirectoryPath $backupDir -applicationName $appName
        }

        AfterEach {
            # Delete all the zip files
            Start-Sleep -s 1.5

            $filesToDelete = $backupDir + "\*.zip"
            Remove-Item $filesToDelete
        }

        It 'does not delete any backup files' {
            Test-Path $backupFile1.FullName | Should -Be $true
            Test-Path $backupFile2.FullName | Should -Be $true
            Test-Path $backupFile3.FullName | Should -Be $true
        }
    }

        Context "when there are more than two backup files older than 2 weeks" {
            BeforeEach {
                $currentDate = Get-Date

                $backupFile1 = New-Item -Path $backupDir -ItemType "file" -Name "$appName-33333333-3333.zip" -Force
                $backupFile1.LastWriteTime = $currentDate.AddDays(-14)

                $backupFile2 = New-Item -Path $backupDir -ItemType "file" -Name "$appName-44444444-4444.zip" -Force
                $backupFile2.LastWriteTime = $currentDate.AddDays(-14);

                $backupFile3 = New-Item -Path $backupDir -ItemType "file" -Name "$appName-55555555-5555.zip" -Force
                $backupFile3.LastWriteTime = $currentDate.AddDays(-14);

                # Create a fourth backup file with appName.beta, this should not get picked up for deletion
                $backupFile4 = New-Item -Path $backupDir -ItemType "file" -Name "$appName.beta-66666666-6666.zip" -Force
                $backupFile4.LastWriteTime = $currentDate.AddDays(-14);

                # Run script
                $script = $rootDir + "\Backup-Application.ps1"
                & $script -sourceDirectoryPath $sourceDir -backupDirectoryPath $backupDir -applicationName $appName
            }

            AfterEach {
                Start-Sleep -s 1.5

                # Delete all the zip files
                $filesToDelete = $backupDir + "\*.zip"
                Remove-Item $filesToDelete
            }

            It 'only keeps the latest 2 backup files' {
                Test-Path $backupFile1.FullName | Should -Be $true
                Test-Path $backupFile2.FullName | Should -Be $true
                Test-Path $backupFile3.FullName | Should -Be $false
            }

            It 'only keeps the latest 2 backup files with same app name' {
                Test-Path $backupFile1.FullName | Should -Be $true
                Test-Path $backupFile2.FullName | Should -Be $true
                Test-Path $backupFile3.FullName | Should -Be $false
                Test-Path $backupFile4.FullName | Should -Be $true
            }
        }
    }
