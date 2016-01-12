## include puppet modules
include wget

# variables
$rpm_package_epel = 'http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm'
$rpm_package_remi = 'http://rpms.famillecollet.com/enterprise/remi-release-7.rpm'
$php_packages     = ['php', 'php-gd', 'php-mysql', php-mcrypt']

## define $PATH for all execs
Exec {path => ['/usr/bin/']}

## download rpm package(s)
exec {'download-rpm-package':
    command => "wget ${rpm_package_epel} && wget ${rpm_package_remi}",
    notify => Exec['install-rpm-package'],
    cwd => '/home/vagrant/',
}

## install rpm package(s)
exec {'install-rpm-package':
    command => "rpm -Uvh ${rpm_package_epel} && rpm -Uvh ${rpm_package_remi}",
    refreshonly => true,
    notify => Exec['remove-rpm-package'],
    cwd => '/home/vagrant/',
}

## remove unnecessary rpm packages
exec {'remove-rpm-package':
    command => 'rm *.rpm',
    refreshonly => true,
    notify => Exec['add-epel'],
    cwd => '/home/vagrant/',
}

## add EPEL Repository, which allows 'phpmyadmin' to be installed
exec {'add-epel':
    command => 'yum -y install epel-release --enablerepo=extras',
    refreshonly => true,
    notify => Exec['update-yum'],
    timeout => 450,
}

## update yum using the added EPEL repository
exec {'update-yum':
    command => 'yum -y update',
    refreshonly => true,
    notify => Exec['install-phpmyadmin'],
    timeout => 750,
}

## install phpmyadmin: requires the above 'add-epel', and 'update-yum'
exec {'install-phpmyadmin':
    command => 'yum -y install phpmyadmin',
    refreshonly => true,
    notify => Exec['enable-php-56-repo'],
}

## enable repo to install php 5.6
exec {'enable-php-56-repo-1':
    command => 'awk "/[remi-php56]/,/[remi-test]/ { if (/enabled=0/) \$0 = \"enabled=1\" }1"  /etc/yum.repos.d/remi.repo > /home/vagrant/remi.tmp',
    refreshonly => true,
    notify => Exec['enable-php-56-repo-2'],
}
exec {'enable-php-56-repo-2':
    command => 'mv /home/vagrant/remi.tmp /etc/yum.repos.d/remi.repo',
    refreshonly => true,
    before => Package[$php_packages],
}

## install php
package {$php_packages:
    ensure => present,
    notify => Exec['phpmyadmin-access-1'],
    before => Exec['phpmyadmin-access-1'],
}

## allow phpmyadmin access from guest VM to host (part 1)
#
#  Note: this segment appends directly below <Directory /usr/share/phpMyAdmin/>
exec {'phpmyadmin-access-1':
    command => 'sed -i "12i\Order allow,deny" /etc/httpd/conf.d/phpMyAdmin.conf',
    refreshonly => true,
    notify => Exec['phpmyadmin-access-2'],
}

## allow phpmyadmin access from guest VM to host (part 2)
#
#  Note: this segment appends directly below (part 1)
exec {'phpmyadmin-access-2':
    command => 'sed -i "13i\Allow from all" /etc/httpd/conf.d/phpMyAdmin.conf',
    refreshonly => true,
    notify => Exec['php-memory-limit'],
}

## increase php memory limit (i.e. bootstrap 3 theme)
exec {'php-memory-limit':
    command => 'sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/php.ini',
    refreshonly => true,
}