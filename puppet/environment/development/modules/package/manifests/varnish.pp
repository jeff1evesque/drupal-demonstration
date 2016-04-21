### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class package::varnish {
    ## install package
    #
    #  Note: the 'varnish' package, is installed via the following syntax:
    #
    #        <package name>-<version info>
    package { 'varnish-4.0.3-3.el7.x86_64':
        ensure => 'installed',
    }
}