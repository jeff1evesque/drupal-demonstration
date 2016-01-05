## variables
$ssl_country  = 'US'
$ssl_state    = 'VA'
$ssl_city     = 'city'
$ssl_org_name = 'organizational name'
$ssl_org_unit = 'organizational unit'
$ssl_cname    = 'localhost'

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
    notify => Exec['adjust-firewalld-ssl'],
}

## adjust firewalld, which allows guest port 443 to be accessible on the host machine
exec {'adjust-firewalld-ssl':
    command => 'firewall-cmd --add-port=443/tcp --permanent',
    refreshonly => true,
    notify => Exec['restart-firewalld-ssl'],
}

## restart firewalld (ssl)
exec {'restart-firewalld-ssl':
    command => 'firewall-cmd --reload',
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
    command => 'sed -i "s/\SSLCertificateKeyFile \/etc\/pki\/tls\/private\/localhost.key/SSLCertificateKeyFile \/etc\/httpd\/ssl\/httpd.key/g" /etc/httpd/conf.d/ssl.conf',
    refreshonly => true,
    notify => Exec['restart-httpd'],
}

## restart apache server
exec {'restart-httpd':
    command => 'service httpd restart',
    refreshonly => true,
}
