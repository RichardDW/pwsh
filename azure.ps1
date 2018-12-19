# This keeps me from running the whole script in case I accidentally hit F5
if (1 -eq 1) { exit }

####################################################################
#Gets users from Azure Active Directory.
$Users = Get-Msoluser -all
# Assuming $users has your users
# Assuming $users.upn is the UPN, $users.licenses is licenses
ForEach ($user in $users) {
 ForEach ($license in $user.licenses) {
  $props = @{'UPN'=$user.upn
             'License' = $license}
  New-Object -Type PSObject -Prop $props
 }
}
#=======================================================
