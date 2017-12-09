###
### Configure required composer.
###

class drush::configure_composer {
    exec { 'move-composer-phar':
        command => 'mv composer.phar /usr/bin/composer/composer',
        path    => '/usr/bin',
        cwd     => '/root',
        before  => File['/usr/local/bin/composer'],
        onlyif  => [
            '[ ! -f /usr/bin/composer/composer ]',
            '[ ! -f /root/composer.phar ]',
        ]
    }

    ## symlink composer to path
    file { '/usr/local/bin/composer':
        ensure  => '/usr/bin/composer/composer',
        require => Exec['move-composer-phar'],
    }
}
