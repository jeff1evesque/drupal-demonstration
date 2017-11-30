###
### Configures mongodb instance.
###

class php {
    include php::install_rpm
    include php::enable_rpm
    include php::install_php
    include httpd::restart

    ## enforce resource ordering: applies left resource first, if the left
    ##     resource changes, the right resource will refresh.
    ##
    Class['php::install_rpm'] ~>
    Class['php::enable_rpm'] ~>
    Class['php::install_php'] ~>
    Class['httpd::restart']
}
