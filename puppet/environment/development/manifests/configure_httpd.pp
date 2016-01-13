## include puppet modules
class { 'nodejs':
  repo_url_suffix => 'node_5.x',
}

## variables
$packages_general = ['git', 'httpd', 'gd', 'dos2unix']
$time_zone = 'America/New_York'

## define $PATH for all execs
Exec {path => ['/sbin/', '/usr/bin/', '/bin/']}

## packages: install general packages
package {$packages_general:
    ensure => present,
    before => Service['httpd'],
}

## start compiler service(s), and ensure always running
service {'httpd':
    ensure => 'running',
    enable => true,
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
    notify => Exec['change-docroot'],
}

## change docroot: point docroot to mounted '/vagrant' directory
exec {'change-docroot':
    command => 'sed -i "s/\/var\/www\/html/\/vagrant/g" /etc/httpd/conf/httpd.conf',
    refreshonly => true,
    notify => Exec['adjust-firewalld'],
}

## adjust firewalld, which allows guest port 80 to be accessible on the host machine
exec {'adjust-firewalld':
    command => 'firewall-cmd --add-port=80/tcp --permanent',
    refreshonly => true,
    notify => Exec['restart-firewalld'],
}

## restart firewalld
exec {'restart-firewalld':
    command => 'firewall-cmd --reload',
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
    notify => Exec['restart-httpd'],
}


## restart httpd to allow PHP extensions to load properly (dom, gd)
exec {'restart-httpd':
    command => 'systemctl restart httpd',
    refreshonly => true,
}