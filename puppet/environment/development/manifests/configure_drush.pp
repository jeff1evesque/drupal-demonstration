## variables
$user = 'provisioner'

## define $PATH for all execs
Exec {path => ['/usr/sbin/', '/usr/local/bin/']}

## install, and enable drush
class drush {
    ## drush dependency
    include composer

    ## install drush
    drush::drush { 'drush':
        version    => '8',
        target_dir => '/usr/bin',
    }

    ## define drush alias
    exec { 'drush-alias':
        command => "echo 'alias drush=\'/usr/local/bin/drush\'' >> /home/${user}/.bashrc",
        refreshonly => true,
        notify => Exec['reload-bash-startup-config'],
    }

    ## reload bash startup files
    exec { 'reload-bash-startup-config':
        command => 'source ~/.bashrc',
        refreshonly => true,
        provider => 'shell',
    }
}

## drush: enable clean urls, requires functional drupal instance
class clean_url {
    ## set dependency
    require drush

    exec { 'enable-clean-url':
        command => 'drush vset clean_url 1',
        cwd     => '/vagrant/webroot'
    }
}

## constructor
class constructor {
    contain drush
#    contain clean_url
}
include constructor