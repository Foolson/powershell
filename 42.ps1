################## METADATA ##################
# NAME: Johan Olsson
# USERNAME: d15johol
# COURSE: IT341G
# ASSIGNMENT: Powershell 4.2
# DATE OF LAST CHANGE: 2016-04-03
##############################################

Set-StrictMode -Version Latest

Import-Module ActiveDirectory

# Loop through all relevant OU in the domain
ForEach($OU In (Get-ADOrganizationalUnit -SearchBase 'OU=Accounts,DC=scripting,DC=nsa,DC=his,DC=se' -Filter *)){
    # Specify the shadow group name
    $OUSG = "SG_" + $OU.Name
    # Check if the shadow group exist
    $ShadowGroup = (Get-ADGroup -Filter {Name -Like $OUSG})
    If($ShadowGroup -ne $null){
        # Get the relevant shadow group name
        $ShadowGroupName = $ShadowGroup.Name
        # Loop through each user in the relevant shadow group
        # If the user does not exist in the relevant OU then remove the user from the shadow group
        ForEach($User In (Get-ADGroupMember $ShadowGroup)){
            $UserName = $User.Name
             If(-Not(Get-ADUser -SearchBase $OU.DistinguishedName -Filter {Name -Like $UserName})){
                Remove-ADGroupMember $ShadowGroup -Member $User -Confirm:$false
                Echo "$UserName Removed from $ShadowGroupName"
             }
        }
        # Loop through each user in the relevant OU
        # If the user does not exist in the relevant shadow group then add the user to the shadow group
        ForEach($User In (Get-ADUser -SearchBase $OU.DistinguishedName -Filter *)){
            $UserName = $User.Name
            If(-Not(Get-ADGroupMember -Identity $ShadowGroup | Where {$_.Name -eq $UserName})){
               Add-ADGroupMember $ShadowGroup -Member $User
               Echo "$UserName Added to $ShadowGroupName"
            }
        }    }
}