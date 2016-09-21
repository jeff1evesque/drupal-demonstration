### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class redis_server::configure {
    ## local variables
    $root_dir          = '/vagrant'
    $provisioner       = 'provisioner'
    $template_path     = 'redis_server'
    $build_environment = 'development'
    $script            = 'redis_server'
    $environment_dir   = "${root_dir}/puppet/environment/${environment}"

    ## dos2unix bash script: convert clrf (windows to linux) in case host
    #                    machine is windows.
    file { "${environment_dir}/scripts/${script}":
        ensure  => file,
        content => dos2unix(file("${environment_dir}/scripts/${script}")),
        mode    => '770',
    }

    ## selinux for redis
    exec { 'selinux-redis':
        command => '/usr/sbin/setsebool -P httpd_can_network_connect=1',
    }

    ## ensure redis start on successive boot
    service { 'redis-server':
        enable => true,
    }
}