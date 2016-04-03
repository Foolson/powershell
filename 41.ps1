################## METADATA ##################
# NAME: Johan Olsson
# USERNAME: d15johol
# COURSE: IT341G
# ASSIGNMENT: Powershell 4.1
# DATE OF LAST CHANGE: 2016-03-14
##############################################

Set-StrictMode -Version Latest

Import-Module ActiveDirectory

# Try to get the file from the first cli argument
Try{
    $File = $args[0]
}
# If no cli argument is found ask the user for a file
Catch{
    $File = Read-Host "Full Path To File"
}

# Use import-csv to create custom objects from the csv-file
$Users = Import-Csv -Delimiter "," -Path $File

# Loop through each custom object or user imported from the csv-file
foreach ($User in $Users)
{
    # Specify first and lastname
    $Firstname = $User.Firstname
    $Lastname = $User.Lastname

    # Create a short version of first and lastname combined, remove åäö and add a alphabetic prefix if the username exist
    # The prefix will increase after each test if the username exist
    $prefix = 96
    While($true){
        $prefix++
        $SAM = [char]$prefix + "-" + $Firstname.Substring(0,2).ToLower() + $Lastname.Substring(0,2).ToLower().Replace("å","a").Replace("ä","a").Replace("ö","o")
        If(-Not (Get-ADUser -Filter 'SamAccountName -like $SAM')){
            break
        }
    }

    # Specify the email
    $Email = $SAM + "@scripting.nsa.his.se"

    # Generate a strong random password with the .NET generatepassword method
    $Assembly = Add-Type -AssemblyName System.Web
    $Password = ([System.Web.Security.Membership]::GeneratePassword(20,5))

    # Create the account name, and if the account name exist add a artificial middle name. Which is the same character as the SAM-prefix
    $Seperator = " "
    If(Get-ADUser -Filter 'Name -like $Displayname'){
        $Seperator = " " + $SAM.ToUpper().Substring(0,1) + "." + " "
    }
    $Name = $User.Firstname + $Seperator + $User.Lastname

    # Specify account information such as displayname, department, city and role/title
    $DisplayName = $User.Firstname + " " + $User.Lastname
    $Department = $User.Department
    $City = $User.City
    $Role = $User.Role

    # Create a .txt-file with the username and password
    echo "UserName: $SAM`r`nPassword: $Password`r`n" | Out-File "C:\$SAM.txt"

    # If the users deprartment OU does not exist create it and a matching shadowgroup
    $ShadowGroup = 'SG_' + $Department
    If(-Not (Get-ADOrganizationalUnit -SearchBase 'OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -Filter 'name -like $Department')){
        New-ADOrganizationalUnit -Name $Department -Path 'OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se'
        New-ADGroup -Name $ShadowGroup -Path 'OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -GroupCategory Security -GroupScope Global
    }
    # If the users city group does not exist then create it
    If(-Not (Get-ADGroup -SearchBase 'OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -Filter 'name -like $City')){
        New-ADGroup -Name $City -Path 'OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -GroupCategory Security -GroupScope Global
    }

    # Create a new ActiveDirectory user
    New-ADUser -Name $Name -DisplayName "$DisplayName" -SamAccountName $SAM -Email $Email -UserPrincipalName $Email -GivenName "$Firstname" -Surname "$Lastname" -Path "OU=$Department,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se" -Department $Department -Title $Role -City $City -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true

    # Add the user to the citygroup and the department shadow-group
    $user = Get-ADUser "CN=$Name,OU=$Department,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se";
    $group = Get-ADGroup "CN=$City,OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se";
    Add-ADGroupMember $group –Member $user
    $group = Get-ADGroup "CN=$ShadowGroup,OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se";
    Add-ADGroupMember $group –Member $user
}
