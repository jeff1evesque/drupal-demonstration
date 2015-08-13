## variables
$packages_general = ['git', 'httpd', 'mysql-server', 'php', 'php-mysql', 'php-pear', 'gd']
$drush_console_table = 'Console_Table-1.1.5'
$time_zone = 'America/New_York'
$rpm_packages = ['http://rpms.famillecollet.com/enterprise/remi-release-6.rpm', 'http://rpms.famillecollet.com/enterprise/remi-release-6.rpm']
$rpm_packages_size  = size($rpm_packages) - 1
$rpm_files = ['remi-release-6*.rpm', 'epel-release-6*.rpm']
$rpm_files_size  = size($rpm_files) - 1

## define $PATH for all execs
Exec {path => ['/sbin/', '/usr/bin/', '/bin/']}

## packages: install general packages
package {$packages_general:
    ensure => present,
    notify => Exec['start-services'],
    before => Exec['start-services'],
}

## start apache, and mysql server: required for the initial time
exec {'start-services':
    command => 'service httpd start && service mysqld start',
    refreshonly => true,
    notify => Exec['autostart-services'],
}

## autostart apache, and mysql server: this ensure apache, and mysql runs after reboot
exec {'autostart-services':
    command => 'chkconfig httpd on && chkconfig mysqld on',
    refreshonly => true,
    notify => Exec['add-epel'],
}

## add EPEL Repository, which allows 'phpmyadmin' to be installed
exec {'add-epel':
    command => "yum -y install epel-release --enablerepo=extras",
    refreshonly => true,
    notify => Exec['update-yum'],
    timeout => 450,
}

## update yum using the added EPEL repository
exec {'update-yum':
    command => 'yum -y update',
    refreshonly => true,
    notify => Exec['install-phpmyadmin'],
    timeout => 450,
}

## install phpmyadmin: requires the above 'add-epel', and 'update-yum'
exec {'install-phpmyadmin':
    command => 'yum -y install phpmyadmin',
    refreshonly => true,
    notify => Exec['define-errordocument-403'],
}

## define errordocument for 403 'bad request'
exec {'define-errordocument-403':
    command => 'sed "/\ErrorDocument 402/a ErrorDocument 400 \/error.php" /etc/httpd/conf/httpd.conf > /vagrant/httpd.conf.tmp',
    refreshonly => true,
    notify => Exec['mv-httpd-conf-403'],
}

## move bad request logic
exec {'mv-httpd-conf-403':
    command => 'mv /vagrant/httpd.conf.tmp /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['remove-comment-errordocument-1'],
}

## remove comment (part 1): remove '# Some examples:' line.
exec {'remove-comment-errordocument-1':
    command => 'sed "/\# Some examples:/d" /etc/httpd/conf/httpd.conf > /vagrant/httpd.conf.tmp',
    refreshonly => true,
    notify => Exec['mv-httpd-conf-comment-1'],
}
exec {'mv-httpd-conf-comment-1':
    command => 'mv /vagrant/httpd.conf.tmp /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['define-http-400'],
}

## define errordocument for 400 'bad request'
exec {'define-http-400':
    command => 'sed "/\\#ErrorDocument 402/a ErrorDocument 400 \/error.php" /etc/httpd/conf/httpd.conf > /vagrant/httpd.conf.tmp',
    refreshonly => true,
    notify => Exec['mv-httpd-conf-400'],
}
exec {'mv-httpd-conf-400':
    command => 'mv /vagrant/httpd.conf.tmp /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['remove-comment-errordocument-2'],
}

## remove comment (part 2): remove line after 'ErrorDocument 400 /error.php'.
exec {'remove-comment-errordocument-2':
    command => 'sed -e "/ErrorDocument 400 \/error.php/{N;s/\n.*//;}" /etc/httpd/conf/httpd.conf > /vagrant/httpd.conf.tmp',
    refreshonly => true,
    notify => Exec['mv-httpd-conf-comment-2'],
}
exec {'mv-httpd-conf-comment-2':
    command => 'mv /vagrant/httpd.conf.tmp /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['phpmyadmin-access-1'],
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
    notify => Exec['change-docroot'],
}

## change docroot: point docroot to mounted '/vagrant' directory
exec {'change-docroot':
    command => 'sed -i "s/\/var\/www\/html/\/vagrant/g" /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['adjust-iptables'],
}

## adjust iptables, which allows guest port 80 to be accessible on the host machine
exec {'adjust-iptables':
    command => 'sed -i "11i\-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT" /etc/sysconfig/iptables',
    refreshonly => true,
    notify => Exec['restart-iptables'],
}

## restart iptables
exec {'restart-iptables':
    command => 'service iptables restart',
    refreshonly => true,
    notify => Exec['install-drush'],
}

## install drush
exec {'install-drush':
    command => 'pear channel-discover pear.drush.org && pear install drush/drush',
    refreshonly => true,
    notify => Exec['install-drush-dependency'],
}

## drush requirement: need to install Console_Table-x.x.x
exec {'install-drush-dependency':
    command => "pear install ${drush_console_table}",
    refreshonly => true,
    notify => Exec['allow-htaccess-1'],
}

## allow htaccess (part 1): replace 'AllowOverride None', with 'AllowOverride All' between the starting
#                           delimiter '<Directory />', and ending delimiter '</Directory>'.
exec {'allow-htaccess-1':
    command => 'awk "/<Directory \/>/,/<\/Directory>/ { if (/AllowOverride None/) \$0 = \"    AllowOverride All\" }1"  /etc/httpd/conf/httpd.conf > /vagrant/httpd.conf.tmp',
    refreshonly => true,
    notify => Exec['mv-httpd-conf-htaccess-1'],
}

## move htaccess access (part 1): an attempt to write the results directly to 'httpd.conf' in the above
#                                 'allow htaccess (part 1)' step, results in an empty 'httpd.conf' file.
#                                 Therefore, the temporary 'httpd.conf.tmp', and this corresponding 'mv'
#                                 step is required.
exec {'mv-httpd-conf-htaccess-1':
    command => 'mv /vagrant/httpd.conf.tmp /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['allow-htaccess-2'],
}

## allow htaccess (part 2): replace 'AllowOverride None', with 'AllowOverride All' between the starting
#                           delimiter '<Directory "/vagrant">', and ending delimiter '</Directory>'.
exec {'allow-htaccess-2':
    command => 'awk "/<Directory \"\/vagrant\">/,/<\/Directory>/ { if (/AllowOverride None/) \$0 = \"    AllowOverride All\" }1"  /etc/httpd/conf/httpd.conf > /vagrant/httpd.conf.tmp',
    refreshonly => true,
    notify => Exec['mv-httpd-conf-htaccess-2'],
}

## move htaccess access (part 2): an attempt to write the results directly to 'httpd.conf' in the above
#                                 'allow htaccess (part 2)' step, results in an empty 'httpd.conf' file.
#                                 Therefore, the temporary 'httpd.conf.tmp', and this corresponding 'mv'
#                                 step is required.
exec {'mv-httpd-conf-htaccess-2':
    command => 'mv /vagrant/httpd.conf.tmp /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['set-time-zone'],
}

## define system timezone
exec {'set-time-zone':
    command => "rm /etc/localtime && ln -s /usr/share/zoneinfo/${time_zone} /etc/localtime",
    refreshonly => true,
    notify => Exec["build-rpm-package-${rpm_packages_size}"],
}

## download rpm packages
each($rpm_packages) |$index, $package| {
    exec {"build-rpm-package-${index}":
        command => "wget $package",
        notify => Exec["install-rpm-package-${rpm_files_size}"],
        refreshonly => true,
        timeout => 1400,
    }
}

## install rpm packages
each($rpm_files) |$index, $file| {
    exec {"install-rpm-package-${index}":
        command => "rpm -Uvh ${file}",
        notify => File["remove-rpm-package-${rpm_files_size}"],
    }
}

## remove unnecessary rpm packages
each($rpm_files) |$index, $file| {
    file {"remove-rpm-package-${index}":
        path => "/vagrant/${file}",
        purge => true,
        notify => Exec['pre-update-php'],
    }
}

## php pre-update : replace 'enabled=0', with 'enabled=1' between the starting
#                           delimiter '[remi]', and ending delimiter '[remi-php55]'.
exec {'pre-update-php':
    command => 'awk "/[remi]/,/[remi-php55]/ { if (/enabled=0/) \$0 = \"enabled=1\" }1"  /etc/yum.repos.d/remi.repo > /etc/yum.repos.d/remi.repo',
    refreshonly => true,
    notify => Exec['restart-services'],
}

## restart services to allow PHP extensions to load properly (dom, gd)
exec {'restart-services':
    command => 'service httpd restart && service mysqld restart',
    refreshonly => true,
}