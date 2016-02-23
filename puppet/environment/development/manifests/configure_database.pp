## install mariadb
class install_db {
    ## mysql::server: install, and configure mariadb-server
    #
    #  @password_hash, default password (can be adjusted via cli)
    #  @max_connections_per_hour, @max_queries_per_hour, @max_updates_per_hour,
    #      @max_user_connections, a zero value indicates no limit
    class {'::mysql::server':
        package_name  => 'mariadb-server',
        root_password => 'password',
        users         => {
            'authenticated@localhost' => {
                ensure                   => 'present',
                max_connections_per_hour => '0',
                max_queries_per_hour     => '0',
                max_updates_per_hour     => '0',
                max_user_connections     => '0',
                password_hash            => mysql_password('password'),
            },
            'provisioner@localhost'   => {
                ensure                   => 'present',
                max_connections_per_hour => '1',
                max_queries_per_hour     => '0',
                max_updates_per_hour     => '0',
                max_user_connections     => '1',
                password_hash            => mysql_password('password'),
            },
        },
        grants        => {
            'authenticated@localhost/db_drupal.*' => {
                ensure     => 'present',
                options    => ['GRANT'],
                privileges => ['INSERT', 'DELETE', 'UPDATE', 'SELECT', 'CREATE', 'DROP', 'ALTER'],
                table      => 'db_drupal.*',
                user       => 'authenticated@localhost',
            },
            'provisioner@localhost/db_drupal.*'   => {
                ensure     => 'present',
                options    => ['GRANT'],
                privileges => ['CREATE'],
                table      => 'db_drupal.*',
                user       => 'provisioner@localhost',
            },
        },
        databases     => {
            'db_drupal' => {
                ensure  => 'present',
                charset => 'utf8',
            },
        },
    }
}

## install mariadb bindings
class install_bindings {	
    ## set dependency
    require install_db

    class {'::mysql::bindings':
        php_enable    => true,
        require       => Class['::mysql::server'],
    }
}

## constructor
class constructor {
    contain install_db
    contain install_bindings
}
include constructor