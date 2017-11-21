###
### Install rpm package needed by php installation.
###

class php::install_php {
    ## local variables
    $php_packages     = [
        'php',
        'php-dom',
        'php-gd',
        'php-mcrypt',
        'php-mysql',
        'php-mbstring',
        'php-opcache'
    ]

    package { $php_packages:
        ensure => present,
    }
}