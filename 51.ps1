################## METADATA ##################
# NAME: Johan Olsson
# USERNAME: d15johol
# COURSE: IT341G
# ASSIGNMENT: Powershell 5.1
# DATE OF LAST CHANGE: 2016-03-15
##############################################

Set-StrictMode -Version Latest

$Year = Get-Date -Format yyyy
$Month = Get-Date -Format MM
$Day = Get-Date -Format dd
$Weekday =  Get-Date -UFormat %u
$Hostname = Hostname

If($Weekday -Like 0){
    Move-Item -Path \\DC01\Backup\$Year\$Month\$Weekday -Destination \\DC01\Backup\$Year\$Month\$Hostname-$Year-$Month-$Day
}

New-Item -ItemType Directory -Force -Path \\DC01\Backup\$Year\$Month\$Weekday

$Policy = New-WBPolicy
$BackupTarget = New-WBBackupTarget -NetworkPath \\DC01\Backup\$Year\$Month\$Weekday
Add-WBBackupTarget -Policy $Policy -Target $BackupTarget
$FileSpec = New-WBFileSpec -FileSpec "C:\Windows\SYSVOL"
Add-WBFileSpec -Policy $Policy -FileSpec $FileSpec
Start-WBBackup -Policy $Policy

If(-Not(Get-EventLog -List | Where {$_.Source -Like "BackupScript"})){
    New-EventLog -LogName Application -Source BackupScript     
}

Write-EventLog -EventId 666 -LogName Application -Message "Backup complete!" -Source BackupScript