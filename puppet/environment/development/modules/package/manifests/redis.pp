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
        destination => "${root}/build/redis-${version}.tar.gz",
        timeout     => 0,
        verbose     => false,
    }
    exec { 'untar-redis-server':
        command => "tar xzvf redis-${version}.tar.gz",
        cwd     => "${root}/build",
        path    => '/bin',
        notify  => Exec['make-redis-server'],
        require => Wget::Fetch['download-redis-server'],
    }

    ## build redis server
    exec { 'make-redis-server':
        command     => 'make',
        cwd         => $cwd,
        path        => '/usr/bin',
        refreshonly => true,
        notify      => Exec['make-install-redis-server'],
        timeout     => 1800,
    }
    exec { 'make-install-redis-server':
        command     => 'make install',
        cwd         => $cwd,
        path        => '/usr/bin',
        refreshonly => true,
        timeout     => 1800,
    }
}
