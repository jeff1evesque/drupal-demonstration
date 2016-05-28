### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class redis::configure {
    ## local variables
    $template_path     = 'redis/server.erb'
    $build_environment = 'development'
    $script            = 'redis_server'

    ## dos2unix systemd: convert clrf (windows to linux) in case host
    #                    machine is windows.
    file { '/etc/systemd/system/redis-systemd.service':
        ensure  => file,
        content => dos2unix(template($template_path)),
    }

    ## selinux: allow httpd to make socket connections
    exec { 'selinux-allow-httpd-socket':
        command => '/usr/sbin/setsebool httpd_can_network_connect=1',
    }
}