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
    $shell_links = {
        'sh'   => [
            '/bin/sh',
            '/usr/bin/sh',
        ],
        'bash' => [
            '/bin/bash',
            '/usr/bin/bash',
        ],
        'nologin' => [
            '/sbin/nologin',
            '/usr/sbin/nologin',
        ],
    }

    ## symlink mode
    $shell_links.each |String $shell_type, Array $files| {
        $files.each |String $file| {
            if $shell_type == 'sh' {
                $ensure_type = link
            }
            else {
                $ensure_type = file
            }

            if $environment != 'development' {
                file { $file:
                    ensure => $ensure_type,
                    target => $shell_type,
                    mode   => '707',
                }
            }
        }
    }
}