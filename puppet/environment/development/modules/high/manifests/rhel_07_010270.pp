### ID: rhel_07_010270
### Severity: High
###
### Description: Configuring this setting for the SSH daemon provides
###              additional assurance that remote login via SSH will require
###              a password, even in the event of misconfiguration elsewhere.
###
### Fix: To explicitly disallow remote login from accounts with empty
###      passwords, add or correct the following line in
###      "/etc/ssh/sshd_config":
###
###      PermitEmptyPasswords no
### 
### Note: Any accounts with empty passwords should be disabled immediately, and
###       PAM configuration should prevent users from being able to assign
###       themselves empty passwords.
###
### Note: the prefix 'high::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class high::rhel_07_010270 {
    ## allow 'file_line' directive
    include stdlib

    ## ensure line
	file_line { '/etc/ssh/sshd_config':
		line  => 'PermitEmptyPasswords no',
  		match => '^PermitEmptyPasswords yes',
	}
}