### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class package::redis {
    ## local variables
    $root        = '/vagrant'
    $cwd         = "${root}/build"
    $verion      = '3.2.0'
    $server_path = "http://download.redis.io/releases/redis-${version}.tar.gz"

    ## download redis
    #
    #  @verbose, defines the verbose attribute for the 'wget' command:
    #
    #      https://github.com/maestrodev/puppet-wget/blob/master/manifests/fetch.pp#L166
    #
    wget::fetch { 'download-redis-server':
        source      => "${server_path}",
        destination => $cwd,
        timeout     => 0,
        verbose     => false,
    }

    ## build redis server
    exec { 'make-redis-server':
        command => 'make',
        cwd     => $cwd,
        path    => '/usr/bin',
        notify  => Exec['make-install-redis-server'],
    }
    exec { 'make-install-redis-server':
        command     => 'make install',
        cwd         => $cwd,
        path        => '/usr/bin',
        refreshonly => true,
    }
}
