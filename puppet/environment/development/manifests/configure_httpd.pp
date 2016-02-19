## include puppet modules
class { 'nodejs':
    repo_url_suffix => 'node_5.x',
}

## install 'mod_ssl' module
class { 'apache::mod::ssl': }

## variables
$vhost_name = 'localhost'
$selinux_policy_dir = '/vagrant/centos7x/selinux/'
$webroot = '/vagrant/webroot'
$port = '80'
$packages_general = ['dos2unix']

## packages: install general packages
package {$packages_general:
    ensure => present,
}

## define $PATH for all execs
Exec {path => ['/sbin/', '/usr/bin/', '/bin/', '/usr/sbin/']}

## install, and configure apache
class httpd {
    ## install apache, without default vhost
    class { 'apache':
        default_vhost => false,
    }

    ## define custom vhost (default not defined)
    apache::vhost { $vhost_name:
        servername       => $vhost_name,
        port             => $port,
        docroot          => $webroot,
        docroot_owner    => 'apache',
        docroot_group    => 'apache',

        directories => [
            {  path           => '/',
               provider       => 'directory',
               allowoverride  => 'None',
               require        => 'all denied',
            },
            {  path           => $webroot,
               provider       => 'directory',
               allowoverride  => 'All',
               require        => 'all granted',
               options        => ['Indexes', 'FollowSymLinks'],
               acceptpathinfo => 'Off',

               error_documents => [
                   { 'error_code' => '401',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '402',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '403',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '404',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '405',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '406',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '407',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '408',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '409',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '411',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '412',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '413',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '414',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '415',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '416',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '417',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '500',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '501',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '502',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '503',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '504',
                     'document'   => "${webroot}/error.php",
                   },
                   { 'error_code' => '505',
                     'document'   => "${webroot}/error.php",
                   },
               ],
            },
        ],
    }
}


## load, and enable selinux policy modules
class selinux {
    ## set dependency
    require httpd

    ## system context: load httpd selinux policy module
    exec {'load-httpd-selinux-policy':
        command => 'semodule -i httpd_t.pp',
        require => [
            Class['apache'],
        ],
        notify  => Exec['enable-httpd-selinux-policy'],
        cwd     => "${selinux_policy_dir}",
    }

    ## system context: enable httpd selinux policy module
    exec {'enable-httpd-selinux-policy':
        command => 'semodule -e httpd_t',
        refreshonly => true,
        cwd     => "${selinux_policy_dir}",
    }
}

## open port(s) to be accessible to the host machine
class firewalld {
    ## set dependency
    require httpd
    require selinux

    ## open general port
    firewalld_port { "allow-port-${port}":
        ensure   => present,
        zone     => 'public',
        port     => $port,
        protocol => 'tcp',
    }
}

## restart apache
class restart_httpd {
    ## set dependency
    require httpd
    require selinux
    require firewalld

    exec { 'restart-httpd':
        command => 'systemctl restart httpd',
    }
}

## constructor
class constructor {
    contain httpd
    contain selinux
    contain firewalld
    contain restart_httpd
}
include constructor
