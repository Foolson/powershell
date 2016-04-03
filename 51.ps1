################## METADATA ##################
# NAME: Johan Olsson
# USERNAME: d15johol
# COURSE: IT341G
# ASSIGNMENT: Powershell 5.1
# DATE OF LAST CHANGE: 2016-04-03
##############################################

Set-StrictMode -Version Latest

# Store relevant date/time info in variables
$Year = Get-Date -Format yyyy
$Month = Get-Date -Format MM
$Day = Get-Date -Format dd
$Weekday =  Get-Date -UFormat %u

# Get the system hostname
$Hostname = Hostname

# If it is sunday (day 0) move last weeks sunday backup to new location
If($Weekday -Like 0){
    Move-Item -Path \\DC01\Backup\$Year\$Month\$Weekday -Destination \\DC01\Backup\$Year\$Month\$Hostname-$Year-$Month-$Day
}

# Create the relevant weekday backup folder
New-Item -ItemType Directory -Force -Path \\DC01\Backup\$Year\$Month\$Weekday

# Pick folders to backup and where to put them 
# Then start the backup
$Policy = New-WBPolicy
$BackupTarget = New-WBBackupTarget -NetworkPath \\DC01\Backup\$Year\$Month\$Weekday
Add-WBBackupTarget -Policy $Policy -Target $BackupTarget
$FileSpec = New-WBFileSpec -FileSpec "C:\Windows\SYSVOL"
Add-WBFileSpec -Policy $Policy -FileSpec $FileSpec
Start-WBBackup -Policy $Policy

# Create a new eventlog and write to the eventlog that the backup is done
New-EventLog -LogName Application -Source BackupScript -ErrorAction SilentlyContinue
Write-EventLog -EventId 666 -LogName Application -Message "Backup complete!" -Source BackupScript