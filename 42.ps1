################## METADATA ##################
# NAME: your full name
# USERNAME: your login name
# COURSE: this course’s name
# ASSIGNMENT: name and number of assignment
# DATE OF LAST CHANGE: date in ISO~8601
##############################################

Set-StrictMode -Version Latest

Import-Module ActiveDirectory

ForEach($OU in (Get-ADOrganizationalUnit -SearchBase 'OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -Filter *)){
    $OUName = $OU.Name    $GroupName = "SG_" + $OUName
    ForEach($ShadowGroup in (Get-ADGroup -SearchBase 'OU=Roles,OU=Groups,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -Filter 'name -like $GroupName')){
        ForEach($User in (Get-ADGroupMember $ShadowGroup)){
            $UserName = $User.Name
             If(-Not(Get-ADUser -SearchBase "OU=$OUName,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se" -Filter 'Name -like $UserName')){
                Echo "$UserName Not Found In $OUName"
                Remove-ADGroupMember $ShadowGroup -Member $User -Confirm:$false
                Echo "Removed $UserName"
             }
        }
        ForEach($User in (Get-ADUser -SearchBase "OU=$OUName,OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se" -Filter *)){
            $UserName = $User.Name
            If(-Not(Get-ADGroupMember $ShadowGroup -Identity $User)){
                $ShadowGroupName =$ShadowGroup.Name
                Echo "$UserName Not Found In $ShadowGroupName" 
            }
        }
    }
}