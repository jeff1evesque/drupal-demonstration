###
### Install drush.
###

class drush::install_composer {
    include httpd

    exec { 'initialize-drush':
        command     => "composer global require drush/drush:${version}",
        path        => ['/usr/bin', '/usr/bin/composer'],
        environment => [
            'COMPOSER_HOME=/usr/bin/composer',
        ],
        provider    => 'shell',
        require     => File['/usr/local/bin/composer'],
        notify      => Exec['update-composer'],
    }

    exec { 'update-composer':
        command     => 'composer global update',
        cwd         => '/usr/bin/composer/cache/files',
        environment => ['COMPOSER_HOME=/usr/bin/composer'],
        provider    => 'shell',
        refreshonly => true,
        before      => File['/usr/local/bin/drush'],
        notify      => Exec['restart-httpd'],
    }

    ## symlink drush to path
    file { '/usr/local/bin/drush':
        ensure      => '/usr/bin/composer/vendor/drush/drush/drush',
        require     => Exec['initialize-drush'],
        notify      => [
            Exec['restart-httpd'],
            Exec['drush-rc'],
        ],
    }

    ## clear cache and registry
    exec { 'drush-rc':
        command     => 'drush rc',
        path        => '/usr/local/bin',
        refreshonly => true,
    }
}
