################## METADATA ##################
# NAME: Johan Olsson
# USERNAME: d15johol
# COURSE: IT341G
# ASSIGNMENT: Powershell 4.2
# DATE OF LAST CHANGE: 2016-03-15
##############################################

Set-StrictMode -Version Latest

Import-Module ActiveDirectory

ForEach($OU In (Get-ADOrganizationalUnit -SearchBase 'OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -Filter *)){
    $OUSG = "SG_" + $OU.Name
    $ShadowGroup = (Get-ADGroup -Filter {Name -Like $OUSG})
    If($ShadowGroup -ne $null){
        $ShadowGroupName = $ShadowGroup.Name
        ForEach($User In (Get-ADGroupMember $ShadowGroup)){
            $UserName = $User.Name
             If(-Not(Get-ADUser -SearchBase $OU.DistinguishedName -Filter {Name -Like $UserName})){
                Remove-ADGroupMember $ShadowGroup -Member $User -Confirm:$false
                Echo "$UserName Removed from $ShadowGroupName"
             }
        }
        ForEach($User In (Get-ADUser -SearchBase $OU.DistinguishedName -Filter *)){
            $UserName = $User.Name
            If(-Not(Get-ADGroupMember -Identity $ShadowGroup | Where {$_.Name -eq $UserName})){
               Add-ADGroupMember $ShadowGroup -Member $User
               Echo "$UserName Added to $ShadowGroupName"
            }
        }    }
}