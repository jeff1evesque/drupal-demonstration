###
### Download required composer.
###

class drush::download_composer {
    exec { 'download-composer':
        command     => 'wget https://getcomposer.org/installer',
        path        => '/usr/bin',
        cwd         => '/root',
        notify      => Exec['move-composer-installer'],
        creates     => [
             '/usr/local/bin/drush',
             '/usr/bin/composer/vendor/drush/drush/drush',
             '/usr/bin/composer/composer',
             '/usr/bin/composer/composer.json',
        ],
        provider    => 'shell',
    }

    exec { 'move-composer-installer':
        command     => 'mv installer composer-installer.php',
        path        => '/usr/bin',
        cwd         => '/root',
        onlyif      => 'test -e /root/installer',
        refreshonly => true,
    }
}
