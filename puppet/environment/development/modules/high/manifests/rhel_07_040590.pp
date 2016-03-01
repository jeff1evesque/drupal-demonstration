### ID: rhel_07_040590
### Severity: High
###
### Description: SSHv1 is an insecure implementation of the SSH protocol and
###              has many well-known vulnerability exploits.  Exploits of the
###              SSH daemon could provide immediate root access to the system.
###
### Fix: Remove all Protocol lines that reference version 1 in all sshd_config
###      files on the system.  The "Protocol" line must be as follows:
###
###      grep Protocol /etc/ssh/sshd_config
###
### Note: If any protocol line other than "Protocol 2" is uncommented, this is
###       a finding.
###
### Note: the prefix 'high::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class high::rhel_07_040590.pp {
    ## allow 'file_line' directive
    include stdlib

    ## remove multiple protocols
	file_line { 'remove-multiple-protocols':
        line  => 'Protocol 2',
		path  => '/etc/ssh/sshd_config', 
  		match => '^.*Protocol 2,.*$',
	}

    ## remove protocol 1 (possible multiples)
	file_line { 'remove-protocol-1':
        line  => 'Protocol 2',
		path  => '/etc/ssh/sshd_config', 
  		match => '^.*Protocol 1.*$',
	}

    ## ensure protocol 2
	file_line { 'remove-multiple-protocols':
        line  => 'Protocol 2',
		path  => '/etc/ssh/sshd_config', 
  		match => '^.*Protocol 2',
	}
}