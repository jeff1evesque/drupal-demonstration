###
### Configures drush instance.
###

class drush {
    include drush::download_composer
    include drush::configure_composer
    include drush::install_composer
    include drush::install_drush
    include httpd::restart

    ## enforce resource ordering: applies left resource first, if the left
    ##     resource changes, the right resource will refresh.
    ##
    Class['drush::download_composer'] ~>
    Class['drush::configure_composer'] ~>
    Class['drush::install_composer'] ~>
    Class['drush::install_composer'] ~>
    Class['httpd::restart']
}
