###
### Install required composer.
###

class drush::install_composer {
    exec { 'install-composer':
        command     => 'php composer-installer.php',
        path        => '/usr/bin',
        cwd         => '/root',
        environment => [
            'COMPOSER_HOME=/usr/bin/composer',
        ],
    }
}
