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