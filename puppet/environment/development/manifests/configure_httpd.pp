## include puppet modules
class { 'nodejs':
  repo_url_suffix => 'node_5.x',
}

class { 'apache':
  default_vhost => false,
}

## variables
$packages_general = ['git', 'gd', 'dos2unix']
$time_zone = 'America/New_York'
$selinux_policy_dir = '/vagrant/centos7x/selinux/'

## define $PATH for all execs
Exec {path => ['/sbin/', '/usr/bin/', '/bin/', '/usr/sbin/']}

apache::vhost { 'drupal.demonstration.com':
    port             => '80',
    docroot          => '/vagrant/webroot',
    docroot_owner    => 'apache',
    docroot_group    => 'apache',
    fallbackresource => '/vagrant/webroot/error.php',

    directories => [
        {  path           => '/',
           provider       => 'directory',
           allowoverride  => 'None',
           require        => 'all denied',
        },
        {  path           => '/vagrant/webroot',
           provider       => 'directory',
           allowoverride  => 'None',
           require        => 'all granted',
           options        => 'Options Indexes FollowSymLinks',
           acceptpathinfo => 'Off',

           error_documents => [
               { 'error_code' => '401',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '402',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '403',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '404',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '405',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '406',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '407',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '408',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '409',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '411',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '412',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '413',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '414',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '415',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '416',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '417',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '500',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '501',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '502',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '503',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '504',
                 'document'   => '/vagrant/webroot/error.php',
               },
               { 'error_code' => '505',
                 'document'   => '/vagrant/webroot/error.php',
               },
      ],
        }
    ]
}

## system context: load httpd selinux policy module
exec {'load-httpd-selinux-policy':
    command => 'semodule -i httpd_t.pp',
    notify => Exec['enable-httpd-selinux-policy'],
    cwd => "${selinux_policy_dir}",
}

## system context: enable httpd selinux policy module
exec {'enable-httpd-selinux-policy':
    command => 'semodule -e httpd_t',
    notify => Package[$packages_general],
    cwd => "${selinux_policy_dir}",
}

## packages: install general packages
package {$packages_general:
    ensure => present,
}