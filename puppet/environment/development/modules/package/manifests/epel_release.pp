### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class package::epel-release {
    ## install package
    #
    #  Note: the 'epel-release' package, is installed via the following syntax:
    #
    #        <package name>-<version info>
    package { 'epel-release-7-6':
        ensure => 'installed',
    }
}