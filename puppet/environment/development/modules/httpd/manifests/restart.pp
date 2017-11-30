###
### Restart httpd server.
###

class httpd::restart {
    exec { 'restart-httpd':
        command     => 'service httpd restart',
        path        => '/usr/sbin',
        refreshonly => true,
    }
}
