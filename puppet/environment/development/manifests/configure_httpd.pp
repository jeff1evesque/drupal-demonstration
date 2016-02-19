## include puppet modules
class { 'nodejs':
    repo_url_suffix => 'node_5.x',
}

## variables: non-ssl
$webroot = '/vagrant/webroot'
$port    = '80'

## variables: ssl
$ssl_dir      = '/etc/httpd/ssl'
$port_ssl     = '443'
$ssl_country  = 'US'
$ssl_state    = 'VA'
$ssl_city     = 'city'
$ssl_org_name = 'organizational name'
$ssl_org_unit = 'organizational unit'
$ssl_cname    = 'localhost'

## variables: general
$build_environment  = development
$vhost_name         = 'localhost'
$selinux_policy_dir = '/vagrant/centos7x/selinux/'
$packages_general   = ['dos2unix']

## packages: install general packages
package {$packages_general:
    ensure => present,
}

## define $PATH for all execs
Exec {path => ['/sbin/', '/usr/bin/', '/bin/', '/usr/sbin/']}

## generate ssh key-pair
class generate_keypair {
    exec {'create-keys]':
        command => "openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout ${ssl_dir}/httpd.key -out ${ssl_dir}/httpd.crt -subj '/C=${ssl_country}/ST=${ssl_state}/L=${ssl_city}/O=${ssl_org_name}/OU=${ssl_org_unit}/CN=${ssl_cname}'",
    }
}

## install, and configure apache
class httpd {
    ## set dependency
    require generate_keypair

    ## install apache, without default vhost
    class { 'apache':
        default_vhost    => false,
        default_ssl_key  => "${ssl_dir}/httpd.key",
        default_ssl_cert => "${ssl_dir}/httpd.crt",
    }

    ## standard vhost (default not defined)
    apache::vhost { "${vhost_name}":
        servername       => $vhost_name,
        port             => $port,
        docroot          => $webroot,
        docroot_owner    => 'apache',
        docroot_group    => 'apache',
        redirect_status  => 'permanent',
        redirect_dest    => "https://${vhost_name}.com",

        ## keep in case we remove 'redirect_dest'
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

               error_documents => template("/vagrant/puppet/environment/${build_environment}/template/error_documents.erb"),
            },
        ],
    }

    ## ssl vhost (default not defined)
    apache::vhost { "${vhost_name}_ssl":
        servername       => $vhost_name,
        port             => $port_ssl,
        docroot          => $webroot,
        docroot_owner    => 'apache',
        docroot_group    => 'apache',
        ssl              => true,

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

               error_documents => template("/vagrant/puppet/environment/${build_environment}/template/error_documents.erb"),
            },
        ],
    }
}

## load, and enable selinux policy modules
class selinux {
    ## set dependency
    require generate_keypair
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
        command     => 'semodule -e httpd_t',
        refreshonly => true,
        cwd         => "${selinux_policy_dir}",
    }
}

## open port(s) to be accessible to the host machine
class firewalld {
    ## set dependency
    require generate_keypair
    require httpd
    require selinux

    ## open general, and ssl port
    firewalld_port { "allow-port-${port}":
        ensure   => present,
        zone     => 'public',
        port     => $port,
        protocol => 'tcp',
    }
    firewalld_port { "allow-port-${port_ssl}":
        ensure   => present,
        zone     => 'public',
        port     => $port,
        protocol => 'tcp',
    }
}

## restart apache
class restart_httpd {
    ## set dependency
    require generate_keypair
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
