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
            echo "NOT FOUND"
            break
        }
        echo "FOUND"
    }

    $Email = $SAM + "@scripting.nsa.his.se"
    $Password = ([char[]](Get-Random -Input $(33..126) -Count 12)) -join ""    $Seperator = " "
    $Displayname = $User.Firstname + " " + $User.Lastname
    If(Get-ADUser -Filter 'Name -like $Displayname'){
        $Seperator = " " + $SAM.ToUpper().Substring(0,1) + "." + " " 
    }
    $Name = $User.Firstname + $Seperator + $User.Lastname
    $DisplayName = $User.Firstname + " " + $User.Lastname
    $Department = $User.Department
    $City = $User.City
    $Role = $User.Role

    echo "--------------------------------------------"
    echo "* Displayname : $DisplayName"
    echo "* Name        : $Name"
    echo "* Firstname   : $Firstname"
    echo "* Lastname    : $Lastname"
    echo "* SAM         : $SAM"
    echo "* Email       : $Email"
    echo "* Password    : $Password"
    echo "* City        : $City"
    echo "* Department  : $Department"
    echo "* Title        : $Role"
    echo "$SAM - $Password" | Out-File "C:\Users\Administrator\Documents\GitHub\powershell\$SAM.txt"
    New-ADUser -Name $Name -DisplayName "$DisplayName" -SamAccountName $SAM -Email $Email -UserPrincipalName $Email -GivenName "$Firstname" -Surname "$Lastname" -Department $Department -Title $Role -City $City -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true
}