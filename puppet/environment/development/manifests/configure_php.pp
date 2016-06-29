# variables
$rpm_package_epel = 'http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-7.noarch.rpm'
$rpm_package_remi = 'http://rpms.famillecollet.com/enterprise/remi-release-7.rpm'
$working_dir      = '/home/provisioner'

## define $PATH for all execs
Exec {path => ['/usr/bin/', '/usr/sbin/']}

## download wget
class download_wget {
    include wget
}

## download rpm package(s)
class download_rpm_packages {
    ## set dependency
    require download_wget

    exec {'download-rpm-package':
        command => "wget ${rpm_package_epel} && wget ${rpm_package_remi}",
        cwd => "${working_dir}",
    }
}

## install rpm package(s)
class install_rpm_packages {
    ## set dependency
    require download_wget
    require download_rpm_packages

    exec {'install-rpm-package':
        command => "rpm -Uvh ${rpm_package_epel} && rpm -Uvh ${rpm_package_remi}",
        cwd => "${working_dir}",
    }
}

## remove unnecessary rpm packages
class clean_rpm_packages {
    ## set dependency
    require download_wget
    require download_rpm_packages
    require install_rpm_packages

    exec {'remove-rpm-package':
        command => 'rm *.rpm',
        cwd => "${working_dir}",
    }
}

## update yum using the added EPEL repository
class update_yum {
    ## set dependency
    require download_wget
    require download_rpm_packages
    require install_rpm_packages
    require clean_rpm_packages

    exec {'update-yum':
        command => 'yum -y update',
        timeout => 1800,
    }
}

## enable repo to install php 5.6
class enable_php_repo {
    ## set dependency
    require download_wget
    require download_rpm_packages
    require install_rpm_packages
    require clean_rpm_packages
    require update_yum

    exec {'enable-php-56-repo-1':
        command => 'awk "/\[remi-php56\]/,/\[remi-test\]/ { if (/enabled=0/) \$0 = \"enabled=1\" }1"  /etc/yum.repos.d/remi.repo > /home/provisioner/remi.tmp',
        notify => Exec['enable-php-56-repo-2'],
    }
    exec {'enable-php-56-repo-2':
        command => "mv ${working_dir}/remi.tmp /etc/yum.repos.d/remi.repo",
        refreshonly => true,
    }
}

## install php
class install_php_packages {
    ## set dependency
    require download_wget
    require download_rpm_packages
    require install_rpm_packages
    require clean_rpm_packages
    require update_yum
    require enable_php_repo

    ## variables
    $php_packages = ['php', 'php-gd', 'php-mcrypt', 'php-opcache']

    package { $php_packages:
        ensure => present,
    }
}

## enable opcache
class enable_opcache {
    ## set dependency
    require download_wget
    require download_rpm_packages
    require install_rpm_packages
    require clean_rpm_packages
    require update_yum
    require enable_php_repo
    require install_php_packages

    ## enable opcache
    ini_setting { 'enable_opcache':
        ensure  => present,
        path    => '/etc/php.ini',
        section => 'PHP',
        setting => 'zend_extension',
        value   => 'opcache.so',
    }
}

## install phpmyadmin: requires the above 'add-epel', and 'update-yum'
class install_phpmyadmin {
    ## set dependency
    require download_wget
    require download_rpm_packages
    require install_rpm_packages
    require clean_rpm_packages
    require update_yum
    require enable_php_repo
    require install_php_packages

    exec {'install-phpmyadmin':
        command => 'yum -y install phpmyadmin',
    }
}

## allow phpmyadmin access
class enable_phpmyadmin {
    ## set dependency
    require download_wget
    require download_rpm_packages
    require install_rpm_packages
    require clean_rpm_packages
    require update_yum
    require enable_php_repo
    require install_php_packages
    require install_phpmyadmin

    ## comment out unnecessary 'require' statements
    exec {'phpmyadmin-comment-require-1':
        command => 'awk "/<RequireAny>/,/<\/RequireAny>/ { if (/Require ip 127.0.0.1/) \$0 = \"       #Require ip 127.0.0.1\" }1"  /etc/httpd/conf.d/phpMyAdmin.conf > /home/provisioner/phpMyAdmin.tmp',
        notify => Exec['phpmyadmin-comment-require-2'],
    }
    exec {'phpmyadmin-comment-require-2':
        command => "mv ${working_dir}/phpMyAdmin.tmp /etc/httpd/conf.d/phpMyAdmin.conf",
        refreshonly => true,
        notify => Exec['phpmyadmin-comment-require-3'],
    }
    exec {'phpmyadmin-comment-require-3':
        command => 'awk "/<RequireAny>/,/<\/RequireAny>/ { if (/Require ip ::1/) \$0 = \"       #Require ip ::1\" }1"  /etc/httpd/conf.d/phpMyAdmin.conf > /home/provisioner/phpMyAdmin.tmp',
        refreshonly => true,
        notify => Exec['phpmyadmin-comment-require-4'],
    }
    exec {'phpmyadmin-comment-require-4':
        command => "mv ${working_dir}/phpMyAdmin.tmp /etc/httpd/conf.d/phpMyAdmin.conf",
        refreshonly => true,
        notify => Exec['phpmyadmin-access-1'],
    }

    ## allow phpmyadmin access from guest VM to host (part 1)
    #
    #  Note: this segment appends directly below 'Require ip ::1'
    #
    #  Note: the spacing in '/^       #Require' corresponds to the above defined
    #        stanza 'phpmyadmin-comment-require-3'.
    exec {'phpmyadmin-access-1':
        command => 'sed "/^       #Require ip ::1/a \     Require all granted" /etc/httpd/conf.d/phpMyAdmin.conf > /home/provisioner/phpMyAdmin.conf',
        refreshonly => true,
        notify => Exec['phpmyadmin-access-2'],
    }
    exec {'phpmyadmin-access-2':
        command => "mv ${working_dir}/phpMyAdmin.conf /etc/httpd/conf.d/phpMyAdmin.conf",
        refreshonly => true,
        notify => Exec['phpmyadmin-system-context'],
    }

    ## reset system context on phpMyAdmin.conf (needed for selinux)
    exec {'phpmyadmin-system-context':
        command => 'restorecon /etc/httpd/conf.d/phpMyAdmin.conf',
        refreshonly => true,
    }
}

## increase php memory limit (i.e. bootstrap 3 theme)
class php_configuration {
    ## set dependency
    require download_wget
    require download_rpm_packages
    require install_rpm_packages
    require clean_rpm_packages
    require update_yum
    require enable_php_repo
    require install_php_packages
    require install_phpmyadmin
    require enable_phpmyadmin

    ## set memory limit
    ini_setting { 'adjust_memory_limit':
        ensure  => present,
        path    => '/etc/php.ini',
        section => 'PHP',
        setting => 'memory_limit',
        value   => '512M',
    }
}

## restart httpd
class restart_httpd {
    ## set dependency
    require download_wget
    require download_rpm_packages
    require install_rpm_packages
    require clean_rpm_packages
    require update_yum
    require enable_php_repo
    require install_php_packages
    require enable_opcache
    require install_phpmyadmin
    require enable_phpmyadmin
    require php_configuration

    exec {'restart-httpd':
        command => 'systemctl restart httpd',
    }
}

## constructor
class constructor {
    contain download_wget
    contain download_rpm_packages
    contain install_rpm_packages
    contain clean_rpm_packages
    contain update_yum
    contain enable_php_repo
    contain install_php_packages
    contain enable_opcache
    contain install_phpmyadmin
    contain enable_phpmyadmin
    contain restart_httpd
    contain php_configuration
}
include constructor
