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

function Test-BPMNUsernameAllowedToAccessMES {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)][string]$Username
    )

    $ADUser = get-aduser -Identity $Username -Properties memberof,PrimaryGroup
    $ADUserMemberOfGroupNames = $ADUser.MemberOf | Get-ADGroup | select -ExpandProperty Name
    $ADUserMemberOfGroupNames += $ADUser.PrimaryGroup | Get-ADGroup | select -ExpandProperty Name

    $EmployeeInMES = $ADUser | 
    where {$ADUserMemberOfGroupNames -Contains "Emblem Placement Users"} |
    where {$ADUserMemberOfGroupNames -Contains "Electronic Packing Station Users"}

    [pscustomobject]@{EmployeeInMES = if($EmployeeInMES) {$true} else {$false} }
}

Function Add-BPMNMESUserToOverrideGroup {
    param(
        [parameter(Mandatory)][string]$Username
    )
    $ADUser = get-aduser -Identity $Username -Properties memberof,PrimaryGroup
    Get-ADGroup -Identity "MES Leaders" | Add-ADGroupMember -Members $ADUser
}

Function Remove-BPMNMESUserFromOverrideGroup {
    param(
        [parameter(Mandatory)][string]$Username
    )
    $ADUser = get-aduser -Identity $Username -Properties memberof,PrimaryGroup
    Get-ADGroup -Identity "MES Leaders" | Remove-ADGroupMember -Members $ADUser -Confirm:$false
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

function Get-ManagerSamAccountNameFromEmployeeSamAccountName {
    param(
        $EmployeeSamAccountName
    )
    $EmployeeADUser = Get-ADUser $EmployeeSamAccountName -Properties manager
    $ManagerSamAccountName = get-aduser $EmployeeADUser.Manager | select -ExpandProperty SamAccountName

    if ($ManagerSamAccountName.count -eq 1) {
        [pscustomobject]@{ManagerUsername = $ManagerSamAccountName }
    } else {
        Throw "Searching for the manager of $EmployeeSamAccountName returned $ManagerSamAccountName (None or more than one samaccountname)"
    }
}