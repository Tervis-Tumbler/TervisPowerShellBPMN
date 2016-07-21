function Get-BPMNADUserSAMAccountNameFromName {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)][string]$Name
    )

    $SAMAccountName = Get-ADUser -Filter {name -eq $Name } | 
    select -ExpandProperty SAMAccountName

    if ($SAMAccountName.count -eq 1) {
        [pscustomobject]@{SAMAccountName = $SAMAccountName}
    } else {
        Throw "Searching for $Name returned $SAMAccountName (None or more than one samaccountname)"
    }
}

function Get-BPMNEmployeeOnlyInMES {
    param(
        $Username
    )
    $ADUser = get-aduser -Identity $UserName -Properties emailaddress,memberof,PrimaryGroup
    $ADUserMemberOfGroupNames = $ADUser.MemberOf | Get-ADGroup | select -ExpandProperty Name
    $ADUserMemberOfGroupNames += $ADUser.PrimaryGroup | Get-ADGroup | select -ExpandProperty Name

    $EmployeeOnlyInMES = $ADUser | 
    where emailaddress -eq $null |
    where {$ADUserMemberOfGroupNames.count -eq 3} |
    where {$ADUserMemberOfGroupNames -Contains "Domain Users"} |
    where {$ADUserMemberOfGroupNames -Contains "Emblem Placement Users"} |
    where {$ADUserMemberOfGroupNames -Contains "Electronic Packing Station Users"}

    [pscustomobject]@{EmployeeOnlyInMES = if($EmployeeOnlyInMES) {$true} else {$false} }
}
