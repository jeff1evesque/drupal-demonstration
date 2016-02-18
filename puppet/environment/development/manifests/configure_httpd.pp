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
        {  path     => '/',
           provider => 'directory',
           override => ['all'],
        },
        {  path     => '/vagrant',
           provider => 'directory',
           override => ['all'],
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