### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class package::phpredis {
    ## include necessary modules
    require git

    ## local variables
    $root          = '/vagrant'
    $cwd           = "${root}/build/phpredis"
    $dirs_phpredis = "${root}/build"

    ## ensure phpredis download directory
    file { $dirs_phpredis:
        ensure => 'directory',
        before => Exec['install-phpredis-phpize'],
    }

    ## download phpredis
    vcsrepo { $cwd:
        ensure   => present,
        provider => git,
        source   => 'https://github.com/phpredis/phpredis',
        revision => '2.2.7',
    }

    ## install phpredis
    exec { 'install-phpredis-phpize':
        command => 'phpize',
        cwd     => $cwd,
        path    => '/usr/bin',
        notify  => Exec['install-phpredis-configure'],
    }
    exec { 'install-phpredis-configure':
        command     => './configure',
        provider    => shell,
        cwd         => $cwd,
        path        => $cwd,
        refreshonly => true,
        notify      => Exec['install-phpredis-make'],
    }
    exec { 'install-phpredis-make':
        command     => 'make && make install',
        cwd         => $cwd,
        path        => '/usr/bin',
        refreshonly => true,
    }
}
