### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class redis::allow_socket {
    ## selinux: allow httpd to make socket connections
    exec { 'selinux-allow-httpd-socket':
        command => '/usr/sbin/setsebool httpd_can_network_connect=1',
    }
}
