## variables: non-ssl
$port = '80'

## variables: ssl
$root_dir      = '/vagrant'
$ssl_dir       = '/etc/ssl/httpd'
$port_ssl      = '443'
$port_ssl_host = '6686'
$ssl_country   = 'US'
$ssl_state     = 'VA'
$ssl_city      = 'city'
$ssl_org_name  = 'organizational name'
$ssl_org_unit  = 'organizational unit'
$ssl_cname     = 'localhost'

## variables: general
$webroot            = '/vagrant/webroot'
$build_environment  = development
$vhost_name         = 'localhost'
$selinux_policy_dir = '/vagrant/centos7x/selinux/'
$packages_general   = ['dos2unix']

## packages: install general packages
package {$packages_general:
    ensure => present,
}

## define $PATH for all execs
Exec {path => ['/usr/bin/', '/usr/sbin/']}

## puppet GPG keys
class gpg_puppet {
    ## local variables
    $puppet_gpg_key = 'RPM-GPG-KEY-puppet'

    ## download gpg key
    exec { 'curl-gpg-puppet':
        command => "curl --remote-name --location https://yum.puppetlabs.com/${puppet_gpg_key}",
        path    => '/usr/bin',
        cwd     => $root_dir,
    }

    ## add gpg key
    exec { 'add-gpg-puppet':
        command => "rpm --import ${puppet_gpg_key}"
        path    => '/usr/bin',
        cwd     => $root_dir,
    }

    ## remove gpg key
    file { 'remove-gpg-puppet':
        ensure => 'absent',
        path   => "${root_dir}/${puppet_gpg_key}"
    }
}

## generate ssh key-pair
class generate_keypair {
    ## create directory
    file { $ssl_dir:
        ensure => 'directory',
        before => Exec['create-keys'],
        notify => Exec['create-keys'],
    }

    ## create key-pair
    exec { 'create-keys':
        command => "openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout ${ssl_dir}/httpd.key -out ${ssl_dir}/httpd.crt -subj '/C=${ssl_country}/ST=${ssl_state}/L=${ssl_city}/O=${ssl_org_name}/OU=${ssl_org_unit}/CN=${ssl_cname}'",
        refreshonly => true,
    }
}

## install, and configure apache
class httpd {
    ## set dependency
    require generate_keypair

    ## install apache, without default vhost
    class { 'apache':
        default_vhost    => false,
    }

    ## enable 'mod_headers'
    class { 'apache::mod::headers': }

    ## standard vhost (default not defined)
    apache::vhost { "${vhost_name}":
        servername       => $vhost_name,
        port             => $port,
        docroot          => $webroot,
        redirect_status  => 'permanent',
        redirect_dest    => "https://${vhost_name}:${port_ssl_host}",
    }

    ## ssl vhost (default not defined)
    #
    #  @add_listen, setting to false, prevents 'Listen $port_ssl' directive
    #      within 'ports.conf', which would conflict with similar directive,
    #      found in 'ssl.conf'
    apache::vhost { "${vhost_name}_ssl":
        servername      => $vhost_name,
        port            => $port_ssl,
        add_listen      => false,
        docroot         => $webroot,
        ssl             => true,
        ssl_cert        => "${ssl_dir}/httpd.crt",
        ssl_key         => "${ssl_dir}/httpd.key",
        error_documents => [
            {
                'error_code' => '400',
                'document'   => '/error.php',
            },
        ],

        directories => [
            {
                path            => '/',
                provider        => 'directory',
                allow_override   => 'None',
                require         => 'all denied',
            },
            {
                path            => $webroot,
                provider        => 'directory',
                allow_override   => 'All',
                require         => 'all granted',
                options         => ['Indexes', 'FollowSymLinks'],
                error_documents => [
                    {
                        'error_code' => '401',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '402',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '403',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '404',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '405',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '406',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '407',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '408',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '409',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '411',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '412',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '413',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '414',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '415',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '416',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '417',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '500',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '501',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '502',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '503',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '504',
                        'document'   => '/error.php',
                    },
                    {
                        'error_code' => '505',
                        'document'   => '/error.php',
                    },
                ],
            },
        ],
    }
}

## selinux policy module(s): changing the selinux context for the shared
##     webroot, is not possible (with vagrant). Instead selinux policy
##     module(s) are loaded, and enabled.
##
## Note: for more information:
##
##       https://github.com/mitchellh/vagrant/issues/6970
class selinux {
    ## set dependency
    require generate_keypair
    require httpd

    ## system context: load httpd selinux policy module
    exec { 'load-httpd-selinux-policy':
        command => 'semodule -i httpd_t.pp',
        notify  => Exec['enable-httpd-selinux-policy'],
        cwd     => "${selinux_policy_dir}",
    }

    ## system context: enable httpd selinux policy module
    exec { 'enable-httpd-selinux-policy':
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
        port     => $port_ssl,
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
    contain gpg_puppet
    contain generate_keypair
    contain httpd
    contain selinux
    contain firewalld
    contain restart_httpd
}
include constructor
