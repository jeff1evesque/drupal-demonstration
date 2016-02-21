## install, and enable drush
class drush {
    ## drush dependency
    include composer

    ## install drush
    drush::drush { 'drush':
        version    => '8',
        target_dir => '/usr/bin'
    }
}

## constructor
class constructor {
    contain drush
}
include constructor