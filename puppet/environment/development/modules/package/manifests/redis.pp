### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
### Note: the command 'yum list redis\*' requires epel to be installed:
###
###       yum --enablerepo=extras install epel-release
###
class package::redis {
    notify {$::redis_version:}

    class { 'redis':
        package_ensure => $::redis_version,
    }
}