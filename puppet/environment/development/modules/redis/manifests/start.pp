### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class redis::start {
    ## start redis server
    service { 'redis-systemd':
        ensure => 'running',
        enable => true,
    }
}