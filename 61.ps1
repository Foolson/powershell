################## METADATA ##################
# NAME: Johan Olsson
# USERNAME: d15johol
# COURSE: IT341G
# ASSIGNMENT: Powershell 6.1
# DATE OF LAST CHANGE: 2016-04-03
##############################################

Set-StrictMode -Version Latest

# Ask user where to save file
$File = Read-Host "Full Path To File"
# Init array
$array = @()

# Loop through all computers in AD
ForEach($Computer In (Get-ADComputer -Filter *).Name){
    # Init new object
    $object = New-Object PSObject

    # Proceed in the loop if connection test is successful
    If((Test-Connection $Computer -Count 1 -Quiet)){
        # Get relevant information about the computer
        $OS = Get-WmiObject -ComputerName $Computer -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption
        $OSVersion = Get-WmiObject -ComputerName $Computer -Class Win32_OperatingSystem | Select-Object -ExpandProperty Version
        $Update = Get-HotFix -ComputerName $Computer | Sort-Object InstalledOn | Select-Object -Last 1 -ExpandProperty InstalledOn 
        $Storage = Get-WmiObject -Computer $Computer -Class Win32_LogicalDisk -Filter "DriveType=3"| Select-Object -ExpandProperty Size
        # Add the storage together to a total sum if there is more than one device
        $TotalStorage = $null
        ForEach($Drive in $Storage){
            $TotalStorage += $Drive
        }
        # Add the free storage together to a total sum if there is more than one device
        $FreeStorage = Get-WmiObject -Computer $Computer -Class Win32_LogicalDisk -Filter "DriveType=3" | Select-Object -ExpandProperty FreeSpace
        $TotalFreeStorage = $null
        ForEach($Drive in $FreeStorage){
            $TotalFreeStorage += $Drive
        }

        # Add the relevant system information to a object
        $object | Add-Member -Name 'Host' -MemberType Noteproperty -Value $Computer
        $object | Add-Member -Name 'OS' -MemberType Noteproperty -Value $OS
        $object | Add-Member -Name 'OS Version' -MemberType Noteproperty -Value $OSVersion
        $object | Add-Member -Name 'Latest Update' -MemberType Noteproperty -Value $Update
        $object | Add-Member -Name 'Storage (GiB)' -MemberType Noteproperty -Value ([math]::Round($TotalStorage / 1073741824))
        $object | Add-Member -Name 'Free Storage (GiB)' -MemberType Noteproperty -Value ([math]::Round($TotalFreeStorage / 1073741824))        # Add the object to an array        $array += $object
    }
}

# Output the array with objects in as an table to the file
$array | Format-Table -Auto >> $File
