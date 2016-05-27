### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class package::redis {
    include wget

    ## local variables
    $root    = '/vagrant'
    $version = '3.2.0'
    $cwd     = "${root}/build/redis-${version}"
    $source  = "http://download.redis.io/releases/redis-${version}.tar.gz"

    ## download redis
    #
    #  @verbose, defines the verbose attribute for the 'wget' command:
    #
    #      https://github.com/maestrodev/puppet-wget/blob/master/manifests/fetch.pp#L166
    #
    wget::fetch { 'download-redis-server':
        source      => "${source}",
        destination => "${root}/build",
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
