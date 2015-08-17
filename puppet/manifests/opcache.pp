## define $PATH for all execs
Exec {path => ['/usr/bin/', '/bin/']}

## create '/vagrant/build/' directory
file {'/vagrant/build/':
    ensure => 'directory',
    before => Vcsrepo['/vagrant/build/opcache'],
}

## clone opcache repository
vcsrepo {'/vagrant/build/opcache':
    ensure => present,
    provider => git,
    source => 'https://github.com/zendtech/ZendOptimizerPlus',
    revision => 'v7.0.5',
    before => Package['php-devel'],
}

## install php-devel: required by 'phpize' command
#
#  Note: the already installed 'gcc' package is also required by the 'phpize'
#        command.
package {'php-devel':
    ensure => 'installed',
    notify => Exec['prepare-opcache'],
    before => Exec['prepare-opcache'],
}

## prepare opcache: prepare extension for compiling
#
#  Note: the opcache installation process requires two packages: 'php-devel',
#        and 'gcc'. However, both have already been installed via the earlier
#        downloaded, and installed remi repository, along with guest additions
#        installation (via vagrant plugin).
#
#  Note: the 'phpize' command needs to be run in a directory containing the
#        'config.m4' file. In this case, the clone '/opcache' directory.
exec {'prepare-opcache':
    command => 'phpize',
	refreshonly => true,
    notify => Exec['configure-opcache'],
    cwd => '/vagrant/build/opcache/',
}

## configure opcache: configure the sources
exec {'configure-opcache':
    command => './configure --with-php-config=$(which php-config)',
    refreshonly => true,
    notify => Exec['compile-opcache'],
    cwd => '/vagrant/build/opcache/',
}

## compile opcache: compile the sources
exec {'compile-opcache':
    command => 'make',
    refreshonly => true,
    notify => Exec['install-opcache'],
    cwd => '/vagrant/build/opcache/',
}

## install opcache: install into PHP extension directory
exec {'install-opcache':
    command => 'make install',
    refreshonly => true,
    #notify => Exec['load-opcache'],
    cwd => '/vagrant/build/opcache/',
}