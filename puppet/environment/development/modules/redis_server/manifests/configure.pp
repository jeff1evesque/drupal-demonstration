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

    ## dos2unix systemd: convert clrf (windows to linux) in case host
    #                    machine is windows.
    file { '/etc/systemd/system/redis-initialize.service':
        ensure  => file,
        content => dos2unix(template("${template_path}/initialize.erb")),
        mode    => '770',
    }
    file { '/etc/systemd/system/redis-server.service':
        ensure  => file,
        content => dos2unix(template("${template_path}/initialize.erb")),
        mode    => '770',
    }

    ## dos2unix bash script: convert clrf (windows to linux) in case host
    #                    machine is windows.
    file { "${environment_dir}/scripts/${script}":
        ensure  => file,
        content => dos2unix(file("${environment_dir}/scripts/${script}")),
        mode    => '770',
    }

    ## selinux for redis
    service { 'redis-initialize':
        ensure => 'running',
        enable => true,
    }

    ## ensure redis start on successive boot
    service { 'redis-server':
        enable => true,
    }
}