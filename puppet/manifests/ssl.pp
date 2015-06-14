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
    command => 'service iptables restart && service httpd start',
    refreshonly => true,
    notify => Exec['assign-ssl-certificate'],
}

## assign certificate in 'ssl.conf' (replace line)
exec {'assign-ssl-certificate':
    command => 'sed -i "s/\SSLCertificateFile \/etc\/pki\/tls\/certs\/localhost.crt/SSLCertificateFile \/etc\/httpd\/ssl\/httpd.crt/g" /etc/httpd/conf.d/ssl.conf',
    refreshonly => true,
    notify => Exec['assign-ssl-key'],
}

exec {'assign-ssl-key':
    command => 'sed -i "s/\SSLCertificateKeyFile \/etc\/pki\/tls\/private\/localhost.key/SSLCertificateFile \/etc\/httpd\/ssl\/httpd.key/g" /etc/httpd/conf.d/ssl.conf',
    refreshonly => true,
    notify => Exec['restart-httpd'],
}

## restart apache server
exec {'restart-httpd':
    command => 'service httpd restart',
    refreshonly => true,
}
