## define $PATH for all execs
Exec {path => ['/usr/bin/', '/usr/local/']}

## include puppet modules
include wget

## install, and enable drush
class drush {
    ## install composer: drush installation dependency
    class { 'composer': }

    ## install drush
    drush::drush { 'drush8':
        version => '8',
    }
}