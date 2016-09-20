### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class redis::start {
    ## start redis server
    service { 'redis':
        ensure => 'running',
        enable => true,
    }

    ## selinux for redis
    service { 'redis-initialize':
        ensure => 'running',
        enable => true,
    }
}