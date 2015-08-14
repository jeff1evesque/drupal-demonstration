## define $PATH for all execs
Exec {path => ['/usr/bin/']}

## variables
$opcache_dependencies = ['gcc']

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
    before => Package["${opcache_dependencies}"],
}

## packages: install opcache dependencies (yum)
#
#  Note: the required package 'php-devel' has already been installed via the
#        earlier downloaded, and installed remi repository.
package {$opcache_dependencies:
    ensure => 'installed',
    provider => 'yum',
    before => Exec['prepare-opcache'],
}

## prepare opcache: prepare extension for compiling
exec {'prepare-opcache':
    command => 'phpsize',
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