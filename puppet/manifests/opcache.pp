## variables
$rpm_url_remi = 'http://rpms.famillecollet.com/enterprise/remi-release-6.rpm'
$rpm_package_remi = 'remi-release-6*.rpm'

## download rpm packages
exec {"build-rpm-package-1":
    command => "wget ${rpm_url_remi}",
    refreshonly => true,
    notify => Exec["install-rpm-package-1"],
    cwd => '/home/vagrant/',
    timeout => 1400,
}

## install rpm remi package
#
#  Note: the remi packages requires an already installed 'epel-release-6*.rpm' package.
exec {"install-rpm-package-1":
    command => "rpm -Uvh ${rpm_package_remi}",
    refreshonly => true,
    notify => Exec['remove-rpm-package'],
    cwd => '/home/vagrant/',
}

## remove unnecessary rpm packages
exec {"remove-rpm-package":
    command => "rm ${rpm_package_remi}",
    refreshonly => true,
    notify => Exec['update-php-1'],
    cwd => '/home/vagrant/',
}

## update php (part 1): replace 'enabled=0', with 'enabled=1' between the starting
#                       delimiter '[remi]', and ending delimiter '[remi-php56]'.
exec {'update-php-1':
    command => 'awk "/[remi]/,/[remi-php56]/ { if (/enabled=0/) \$0 = \"enabled=1\" }1"  /etc/yum.repos.d/remi.repo > /home/vagrant/remi.repo',
    refreshonly => true,
    notify => Exec['mv-remi-repo-1'],
}
exec {'mv-remi-repo-1':
    command => 'mv /home/vagrant/remi.repo /etc/yum.repos.d/remi.repo',
    refreshonly => true,
    notify => Exec['update-php-2'],
}

## php update (part 2): replace 'enabled=0', with 'enabled=1' between the starting
#                       delimiter '[remi]', and ending delimiter '[remi-php56]'.
exec {'update-php-2':
    command => 'awk "/[remi-php56]/,/[remi-test]/ { if (/enabled=0/) \$0 = \"enabled=1\" }1"  /etc/yum.repos.d/remi.repo > /home/vagrant/remi.repo',
    refreshonly => true,
    notify => Exec['mv-epel-repo-2'],
}
exec {'mv-epel-repo-2':
    command => 'mv /home/vagrant/remi.repo /etc/yum.repos.d/remi.repo',
    refreshonly => true,
    notify => Exec['update-yum-php'],
}

## php update: update yum for php
exec {'update-yum-php':
    command => 'yum -y update',
    refreshonly => true,
    before => Package['php-opcache'],
    timeout => 450,
}

## install opcache
package {'php-opcache':
    ensure => present,
    notify => Exec['restart-services'],
    before => Exec['restart-services'],
}