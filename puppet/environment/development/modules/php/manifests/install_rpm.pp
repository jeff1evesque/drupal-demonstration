###
### Install rpm package needed by php installation.
###

class php::install_rpm {
    ## local variables
    $remi_version     = 'remi-release-7'
    $remi_package     = "${remi_version}.rpm"
    $rpm_package_epel = 'http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm'
    $rpm_package_remi = "http://rpms.famillecollet.com/enterprise/${remi_package}"
    $working_dir      = '/home/provisioner'

    ## install dependencies
    contain epel
    contain wget

    ## download rpm packages
    exec { 'download-rpm-package':
        command       => "wget ${rpm_package_remi}",
        cwd           => "${working_dir}",
        unless        => "rpm -q ${remi_version}*",
        path          => '/usr/bin',
    }

    ## install rpm packages
    package { 'epel-release': ensure => installed }
    exec { 'install-rpm-package':
        command       => "yum localinstall -y ${remi_package}",
        cwd           => "${working_dir}",
        unless        => "yum list installed '${remi_version}*' >/dev/null",
        path          => '/usr/bin',
        require       => Exec['download-rpm-package'],
        notify        => Exec['remove-rpm-package'],
    }

    ## cleanup downloaded files
    exec { 'remove-rpm-package':
        command       => 'rm -f *.rpm',
        cwd           => "${working_dir}",
        refreshonly   => true,
        path          => '/usr/bin',
    }
}