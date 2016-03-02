### ID: rhel_07_010260
### Severity: High
###
### Description: If an account has an empty password, anyone could log on and
###              run commands with the privileges of that account. Accounts
###              with empty passwords should never be used in operational
###              environments.
###
### Fix: If an account is configured for password authentication but does not
###      have an assigned password, it may be possible to log on to the account
###      without authenticating.
###
###      Remove any instances of the "nullok" option in
###      "/etc/pam.d/system-auth" to prevent logons with empty passwords.
###
### Note: the prefix 'high::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class high::rhel_07_010260 {

}
