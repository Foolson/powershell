################## METADATA ##################
# NAME: your full name
# USERNAME: your login name
# COURSE: this course’s name
# ASSIGNMENT: name and number of assignment
# DATE OF LAST CHANGE: date in ISO~8601
##############################################
Set-StrictMode -Version Latest
Import-Module ActiveDirectory
$Users = Import-Csv -Delimiter "," -Path "C:\Users\Administrator\Documents\GitHub\powershell\users.csv"           
foreach ($User in $Users)            
{            
    $Firstname = $User.Firstname
    $Lastname = $User.Lastname

    $Year = Get-Date -Format yy
    $prefix = 96
    While(1){
        $prefix++
        $SAM = [char]$prefix + "$year" + $Firstname.Substring(0,2).ToLower() + $Lastname.Substring(0,2).ToLower()
        If(-Not (Get-ADUser -Filter 'SamAccountName -like $SAM')){
            break
        }
    }

    $Email = $SAM + "@scripting.nsa.his.se"
    $Password = ([char[]](Get-Random -Input $(33..126) -Count 15)) -join ""    $Seperator = " "
    $Displayname = $User.Firstname + " " + $User.Lastname
    If(Get-ADUser -Filter 'Name -like $Displayname'){
        $Seperator = " " + $SAM.ToUpper().Substring(0,1) + "." + " " 
    }
    $Name = $User.Firstname + $Seperator + $User.Lastname
    $DisplayName = $User.Firstname + " " + $User.Lastname
    $Department = $User.Department
    $City = $User.City
    $Role = $User.Role
    
    echo "UserName: $SAM`r`nPassword: $Password`r`n" | Out-File "C:\Users\Administrator\Documents\GitHub\powershell\$SAM.txt"

    if(-Not (Get-ADOrganizationalUnit -SearchBase 'OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -Filter 'name -like $Department')){
        New-ADOrganizationalUnit -Name $Department -Path 'OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se'
        $ShadowGroup = 'SG_' + $Department
        New-ADGroup -Name $ShadowGroup -Path 'OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -GroupCategory Security -GroupScope Global
    }
    If(-Not (Get-ADGroup -SearchBase 'OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -Filter 'name -like $City')){
        New-ADGroup -Name $City -Path 'OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -GroupCategory Security -GroupScope Global
    }

    New-ADUser -Name $Name -DisplayName "$DisplayName" -SamAccountName $SAM -Email $Email -UserPrincipalName $Email -GivenName "$Firstname" -Surname "$Lastname" -Path "OU=$Department,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se" -Department $Department -Title $Role -City $City -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true
    $user = Get-ADUser "CN=$Name,OU=$Department,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se";
    $group = Get-ADGroup "CN=$City,OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se";
    Add-ADGroupMember $group –Member $user
    $group = Get-ADGroup "CN=$ShadowGroup,OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se";
    Add-ADGroupMember $group –Member $user
}