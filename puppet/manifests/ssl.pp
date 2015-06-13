## define $PATH for all execs
Exec{path => ['/bin/']}

## install 'mod_ssl'
package {'mod_ssl':
    ensure=> 'installed',
    before => File['/etc/httpd/ssl/'],
}

## create a 'ssl' directory
file {'/etc/httpd/ssl/':
    ensure => "directory",
    before => Exec['record-each-certificate'],
    notify => Exec['record-each-certificate'],
}

## create database to keep track of each signed certificate
exec {'record-each-certificate':
    command => "echo '100001' >serial && touch certindex.txt",
    refreshonly => true,
    cwd => '/etc/httpd/ssl',
}
