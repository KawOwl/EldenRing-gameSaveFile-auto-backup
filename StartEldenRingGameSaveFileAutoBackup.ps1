#version 1.1
#author DameNeko

param(  
	[int]$interval
)

$second = 1000
$minute = 60 * $second

"interval params:" + $interval

If($interval -lt 10 * $second)
{
	$interval = 10 * $second
}

"final interval:" + $interval

$sourceIdentifier = "EldenRingGameSaveFileAutoBackup"
$timer = New-Object -TypeName System.Timers.Timer    
$timer.Interval = $interval
$timer.Autoreset = $True
$timer.Enabled = $True

$objectEventArgs = @{
  InputObject = $timer
	EventName = 'Elapsed'
  SourceIdentifier = $sourceIdentifier
}

$action = { Backup-Action }

$EventJob = Register-ObjectEvent @objectEventArgs -Action $action

. $EventJob.Module {
	$SavePath = $HOME + "\AppData\Roaming\EldenRing"
	$BackupFolderName1 = "\EldenRingGameSaveFileAutoBackup"
	$BackupFolderName2 = "\ERGSFAB-BFB"
	$BackupFolderPath1 = $HOME + $BackupFolderName1
	$BackupFolderPath2 = $HOME + $BackupFolderName2
	$DesktopPath = $HOME + "\Desktop"
	$DesktopSymbolicLinkPath = $DesktopPath + "\EldenRingGameSaveFileAutoBackup.lnk"

	function Backup-Save-To-Path {
		param (
			[string]$destinationFolder
		)

		If(!(test-path $destinationFolder))
		{
			New-Item -ItemType Directory -Force -Path $destinationFolder
		}

		$now = Get-Date -Format o | ForEach-Object { $_ -replace ":", "-" }

		$destinationPath = $destinationFolder + "/" + $now + ".zip"
		
		Compress-Archive -Force -Path $SavePath -DestinationPath $destinationPath
	}

	function Backup-Action {
		Backup-Save-To-Path -destinationFolder $BackupFolderPath1
		Backup-Save-To-Path -destinationFolder $BackupFolderPath2

		$DesktopSymbolicLinkPath

		$create_shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut
		$shortcut = $create_shortcut.invoke($DesktopSymbolicLinkPath)
		$shortcut.TargetPath = $BackupFolderPath1
		$shortcut.Description = $sourceIdentifier
		$shortcut.Save()
	}

	Backup-Action
}

$EventJob