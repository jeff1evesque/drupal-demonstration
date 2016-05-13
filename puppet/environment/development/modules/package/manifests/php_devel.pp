### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class package::php_devel {
    package { 'php-devel':
        ensure => 'installed',
    }
}
