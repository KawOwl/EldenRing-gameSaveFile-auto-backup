$second = 1000
$minute = 60 * $second
$sourceIdentifier = "EldenRingGameSaveFileAutoBackup"
$timer = New-Object -TypeName System.Timers.Timer    
$timer.Interval = 10 * $second
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

	function Backup-Save-To-Path {
		param (
			$destinationFolder
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
	}
}

$EventJob