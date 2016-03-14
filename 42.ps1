################## METADATA ##################
# NAME: Johan Olsson
# USERNAME: d15johol
# COURSE: IT341G
# ASSIGNMENT: Powershell 4.2
# DATE OF LAST CHANGE: 2016-03-14
##############################################

Set-StrictMode -Version Latest

Import-Module ActiveDirectory

ForEach($OU in (Get-ADOrganizationalUnit -SearchBase 'OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -Filter *)){
    $OUName = $OU.Name    $GroupName = "SG_" + $OUName
    ForEach($ShadowGroup in (Get-ADGroup -SearchBase 'OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -Filter 'name -like $GroupName')){
        ForEach($User in (Get-ADGroupMember $ShadowGroup)){
            $UserName = $User.Name
             If(-Not(Get-ADUser -SearchBase "OU=$OUName,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se" -Filter 'Name -like $UserName')){
                Remove-ADGroupMember $ShadowGroup -Member $User -Confirm:$false
             }
        }
        ForEach($User in (Get-ADUser -SearchBase "OU=$OUName,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se" -Filter *)){
            $UserName = $User.Name
            If(-Not(Get-ADUser -SearchBase $ShadowGroup.DistinguishedName -Filter 'Name -like $UserName')){
                $ShadowGroupName =$ShadowGroup.Name
                Add-ADGroupMember $ShadowGroup -Member $User 
            }
        }
    }
}