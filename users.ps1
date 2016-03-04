Import-Module ActiveDirectory
$Users = Import-Csv -Delimiter "," -Path "C:\Users\Administrator\Desktop\users.csv"            
foreach ($User in $Users)            
{            
    $Firstname = $User.Firstname
    $Lastname = $User.Lastname

    $Year = Get-Date -Format yy
    $prefix = 96
    While(1){
        $prefix++
        $SAM = [char]$prefix + "$year" + $Firstname.Substring(0,2).ToLower() + $Lastname.Substring(0,2).ToLower()
        $match = Get-aduser -filter ({sAMAccountName -eq $SAM})
        If($match -eq $null){
            break
        }
    }

    $Email = $SAM + "@scripting.nsa.his.se"
    $Password = ([char[]](Get-Random -Input $(35..38 + 42 + 43 + 48..57 + 63..90 + 94 + 97..122) -Count 12)) -join ""
    $Displayname = $User.Firstname + " " + $SAM.Substring(0,3).ToUpper()+ " " + $User.Lastname

    echo "--------------------------------------------"
    echo "* Displayname : $Displayname"
    echo "* Firstname   : $Firstname"
    echo "* Lastname    : $Lastname"
    echo "* SAM         : $SAM"
    echo "* Email       : $Email"
    echo "* Password    : $Password"
}