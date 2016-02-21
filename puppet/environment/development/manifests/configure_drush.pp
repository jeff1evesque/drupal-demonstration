## define $PATH for all execs
Exec {path => ['/usr/bin/', '/usr/local/']}

## install, and enable drush
class drush {
    ## install composer: drush installation dependency
    class { 'composer': }

    ## install drush
    drush::drush { 'drush8':
        version => '8',
    }
}

## constructor
class constructor {
    contain drush
}
include constructor