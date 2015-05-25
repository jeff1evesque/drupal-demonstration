## variables
$packages_general = ['git', 'httpd', 'mysql-server', 'php', 'php-mysql', 'php-pear', 'gd']
$packages_guest_additions = ['gcc', 'kernel-devel-2.6.32-504.16.2.el6.x86_64']
$drush_console_table = 'Console_Table-1.1.5'

## define $PATH for all execs
Exec {path => ['/sbin', '/usr/bin/', '/bin/']}

## packages: install general packages
package {$packages_general:
    ensure => present,
    notify => Exec['start-services'],
    before => Exec['start-services'],
}

# packages: install guest additions packages
package {$packages_guest_additions:
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
    notify => Exec['install-guest-additions'],
}

## install guest additions (for centos) using installed EPEL repository
exec {'install-guest-additions':
    command => '/etc/init.d/vboxadd setup',
    refreshonly => true,
    notify => Exec['phpmyadmin-access-part-1'],
}

## allow phpmyadmin access from guest VM to host (part 1)
#
#  Note: this segment appends directly below <Directory /usr/share/phpMyAdmin/>
exec {'phpmyadmin-access-part-1':
    command => 'sed -i "12i\Order allow,deny" /etc/httpd/conf.d/phpMyAdmin.conf',
    refreshonly => true,
    notify => Exec['phpmyadmin-access-part-2'],
}

## allow phpmyadmin access from guest VM to host (part 2)
#
#  Note: this segment appends directly below (part 1)
exec {'phpmyadmin-access-part-2':
    command => 'sed -i "13i\Allow from all" /etc/httpd/conf.d/phpMyAdmin.conf',
    refreshonly => true,
    notify => Exec['symlink-website'],
}

## create symlink: create symlink between mounted '/vagrant' directory to webserver
exec {'symlink-website':
    command => 'ln -s /vagrant/* /var/www/html',
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
    notify => Exec['allow-clean-url-1'],
}

## allow drupal clean urls (part 1)
exec {'allow-clean-url-1':
    command => 'sed -i "/<Directory \"\/var\/www\/html\">/a \   RewriteEngine on" /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['allow-clean-url-2'],
}

## allow drupal clean urls (part 2)
exec {'allow-clean-url-2':
    command => 'sed -i "/RewriteEngine on/a \   RewriteBase /" /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['allow-clean-url-3'],
}

## allow drupal clean urls (part 3)
exec {'allow-clean-url-3':
    command => 'sed -i "/RewriteBase \//a \   RewriteCond %{REQUEST_FILENAME} \!-f" /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['allow-clean-url-4'],
}

## allow drupal clean urls (part 4)
exec {'allow-clean-url-4':
    command => 'sed -i "/RewriteCond %{REQUEST_FILENAME} \!-f/a \   RewriteCond %{REQUEST_FILENAME} \!-d" /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['allow-clean-url-5'],
}

## allow drupal clean urls (part 5)
exec {'allow-clean-url-5':
    command => 'sed -i "/RewriteCond %{REQUEST_FILENAME} \!-d/a \   RewriteRule ^(.*)$ index.php?q=$1 [L,QSA]" /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['restart-services'],
}

## restart services to allow PHP extensions to load properly (dom, gd)
exec {'restart-services':
    command => 'service httpd restart && service mysqld restart',
    refreshonly => true,
}
