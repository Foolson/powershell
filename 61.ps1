################## METADATA ##################
# NAME: Johan Olsson
# USERNAME: d15johol
# COURSE: IT341G
# ASSIGNMENT: Powershell 6.1
# DATE OF LAST CHANGE: 2016-03-15
##############################################
$File = Read-Host "Full Path To File : "
$array = @()
ForEach($Computer In (Get-ADComputer -Filter *).Name){
    $object = New-Object PSObject
    If((Test-Connection $Computer -Count 1 -Quiet)){
        $OS = Get-WmiObject -ComputerName $Computer -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption
        $OSVersion = Get-WmiObject -ComputerName $Computer -Class Win32_OperatingSystem | Select-Object -ExpandProperty Version
        $Update = Get-HotFix -ComputerName WIN81 | Sort-Object InstalledOn | Select-Object -Last 1 -ExpandProperty InstalledOn 
        $Storage = Get-WmiObject -Computer $Computer -Class Win32_LogicalDisk -Filter "DriveType=3"| Select-Object -ExpandProperty Size
        $TotalStorage = $null
        ForEach($Drive in $Storage){
            $TotalStorage += $Drive
        }
        $FreeStorage = Get-WmiObject -Computer $Computer -Class Win32_LogicalDisk -Filter "DriveType=3" | Select-Object -ExpandProperty FreeSpace
        $TotalFreeStorage = $null
        ForEach($Drive in $FreeStorage){
            $TotalFreeStorage += $Drive
        }
        $object | Add-Member -Name 'OS' -MemberType Noteproperty -Value $OS
        $object | Add-Member -Name 'OS Version' -MemberType Noteproperty -Value $OSVersion
        $object | Add-Member -Name 'Latest Update' -MemberType Noteproperty -Value $Update
        $object | Add-Member -Name 'Storage (GiB)' -MemberType Noteproperty -Value ([math]::Round($TotalStorage / 1073741824))
        $object | Add-Member -Name 'Free Storage (GiB)' -MemberType Noteproperty -Value ([math]::Round($TotalFreeStorage / 1073741824))        $array += $object
    }
}
$array | Format-Table -Auto >> $File
