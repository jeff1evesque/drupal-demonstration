### ID: rhel_07_010440
### Severity: Medium
###
### Description: Failure to restrict system access to authenticated users
###              negatively impacts operating system security.
###
### Fix: Configure the operating system to not allow an unattended or automatic
###      remote logon to the system.
###
###      Edit the appropriate “sshd_config” file to uncomment or add the lines
###      for the “PermitEmptyPasswords”, “PermitUserEnvironment”,
###      “HostbasedAuthentication” keywords and set their values to “no”:
###
###      PermitEmptyPasswords no
###      PermitUserEnvironment no
###      HostbasedAuthentication no
###
### Note: the prefix 'high::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class medium::rhel_07_010440 {
    ## variables
    $sshd_file = '/etc/ssh/sshd_config'

    ## ensure line
    file_line { 'prevent-empty-password':
		path  => $sshd_file,
        line => 'PermitEmptyPasswords no',
   	    match => '^.*PermitEmptyPasswords.*yes.*',
        multiple => true,
    }

    ## ensure line
    file_line { 'prevent-user-environment':
		path  => $sshd_file,
        line => 'PermitUserEnvironment no',
   	    match => '^.*PermitUserEnvironment.*yes.*',
        multiple => true,
    }

    ## ensure line
    file_line { 'prevent-host-authentication':
		path  => $sshd_file,
        line => 'HostbasedAuthentication no',
   	    match => '^.*HostbasedAuthentication.*yes.*',
        multiple => true,
    }

    ## remove duplicate(s)
    exec { 'remove-empty-password':
        command => "sed  -i -e '/PermitEmptyPassword.*no/b' -i -e '/PermitEmptyPassword/d' ${sshd_file}",
        path    => '/usr/bin',
    }

    ## remove duplicate(s)
    exec { 'remove-user-environment':
        command => "sed  -i -e '/PermitUserEnvironment.*no/b' -i -e '/PermitUserEnvironment/d' ${sshd_file}",
        path    => '/usr/bin',
    }

    ## remove duplicate(s)
    exec { 'remove-host-authentication':
        command => "sed  -i -e '/HostbasedAuthentication.*no/b' -i -e '/HostbasedAuthentication/d' ${sshd_file}",
        path    => '/usr/bin',
    }
}