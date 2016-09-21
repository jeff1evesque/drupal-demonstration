### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class redis_server::configure {
    ## selinux for redis
    exec { 'selinux-redis':
        command => '/usr/sbin/setsebool -P httpd_can_network_connect=1',
        notify  => Exec['redis-daemonize'],
    }

    ## ensure redis start on successive boot
    #
    #  Note: the puppet 'service' directive won't work, since the 'redis'
    #        module has already defined this service, without persistence.
    #
    exec { 'redis-daemonize':
        command     => 'systemctl enable redis.service',
        refreshonly => true,
        path        => '/usr/bin',
    }
}