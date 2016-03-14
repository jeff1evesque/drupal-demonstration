### ID: rhel_07_020930
### 
### Severity: High
###
### Description: Shells with world/group write permissions give the ability to
###              maliciously modify the shell to obtain unauthorized access.
###
### Fix: Change the mode of the shell file to “0755” with the following command:
###
###      chmod 0755
###
class high::rhel_07_020930 {
    ## variables
    $shell_files = [
        '/bin/sh',
        '/bin/bash',
        '/sbin/nologin',
        '/usr/bin/sh',
        '/usr/bin/bash',
        '/usr/sbin/nologin'
    ]

    file { $shell_files:
        ensure  => file,
        mode    => '755',
    }
}