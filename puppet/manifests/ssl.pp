## variables
$ssl_country  = 'US'
$ssl_state    = 'VA'
$ssl_city     = 'city'
$ssl_org_name = 'organizational name'
$ssl_org_unit = 'organizational unit'
$ssl_cname    = 'localhost.dev'

## define $PATH for all execs
Exec{path => ['/bin/', '/usr/bin/', '/sbin/']}

## install 'mod_ssl'
package {'mod_ssl':
    ensure=> 'installed',
    before => File['/etc/httpd/ssl/'],
}

## create a 'ssl' directory
file {'/etc/httpd/ssl/':
    ensure => "directory",
    before => Exec['create-ssl'],
    notify => Exec['create-ssl'],
}

## create ssl key, and certificate
exec {'create-ssl':
    command => "openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/httpd/ssl/httpd.key -out /etc/httpd/ssl/httpd.crt -subj '/C=${ssl_country}/ST=${ssl_state}/L=${ssl_city}/O=${ssl_org_name}/OU=${ssl_org_unit}/CN=${ssl_cname}'",
    refreshonly => true,
    notify => Exec['adjust-iptables'],
}

## adjust iptables, which allows guest port 80 to be accessible on the host machine
exec {'adjust-iptables':
    command => 'sed "/\-A INPUT -m state --state NEW -m tcp -p tcp --dport 80/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT" /etc/sysconfig/iptables',
    refreshonly => true,
    notify => Exec['restart-iptables'],
}

## restart iptables
exec {'restart-iptables':
    command => 'service iptables restart',
    refreshonly => true,
    notify => Exec['assign-ssl-certificate'],
}

## assign certificate in 'ssl.conf'
exec {'assign-ssl-certificate':
    command => 'sed "/\SSLCertificateFile \/etc\/pki\/tls\/certs\/localhost.crt/a SSLCertificateFile \/etc\/httpd\/ssl\/httpd.crt" /etc/httpd/conf.d/ssl.conf > /vagrant/ssl.conf.tmp',
    refreshonly => true,
    notify => Exec['mv-ssl-cnf-1'],
}

## move ssl.conf (part 1): an attempt to write the results directly to 'ssl.conf'
#                          in the above 'assign certificate ..' step, results in
#                          an empty 'ssl.conf' file. Therefore, the temporary
#                          'ssl.conf.tmp', and this corresponding 'mv' step is
#                          required.
exec {'mv-ssl-cnf-1':
    command => 'mv /vagrant/ssl.conf.tmp /etc/httpd/conf.d/ssl.conf',
    refreshonly => true,
    notify => Exec['assign-ssl-key'],
}

## assign key in 'ssl.conf'
exec {'assign-ssl-key':
    command => 'sed "/\SSLCertificateKeyFile \/etc\/pki\/tls\/private\/localhost.key/a SSLCertificateFile \/etc\/httpd\/ssl\/httpd.key" /etc/httpd/conf.d/ssl.conf > /vagrant/ssl.conf.tmp',
    refreshonly => true,
    notify => Exec['mv-ssl-cnf-2'],
}

## move ssl.conf (part 2): an attempt to write the results directly to 'ssl.conf'
#                          in the above 'assign key ..' step, results in an empty
#                          'ssl.conf' file. Therefore, the temporary 'ssl.conf.tmp',
#                          and this corresponding 'mv' step is required.
exec {'mv-ssl-cnf-2':
    command => 'mv /vagrant/ssl.conf.tmp /etc/httpd/conf.d/ssl.conf',
    refreshonly => true,
    notify => Exec['restart-httpd'],
}

## restart apache server
exec {'restart-httpd':
    command => 'service httpd restart',
    refreshonly => true,
}
