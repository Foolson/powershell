################## METADATA ##################
# NAME: Johan Olsson
# USERNAME: d15johol
# COURSE: IT341G
# ASSIGNMENT: Powershell 4.2
# DATE OF LAST CHANGE: 2016-03-14
##############################################

Set-StrictMode -Version Latest

$Year = Get-Date -Format yyyy
$Month = Get-Date -Format MM
$Day = Get-Date -Format dd
$Weekday =  Get-Date -UFormat %u

New-Item -ItemType Directory -Force -Path \\DC01\Backup\$Year\$Month\$Weekday

If(-Not($Weekday -Like "7")){
    $Policy = New-WBPolicy
    $BackupTarget = New-WBBackupTarget -NetworkPath \\DC01\Backup\$Year\$Month\$Weekday
    #Add-WBBackupTarget -Policy $Policy -Target $BackupTarget
}