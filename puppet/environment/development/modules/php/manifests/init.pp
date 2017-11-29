###
### Configures mongodb instance.
###

class php {
    contain php::install_rpm
    contain php::enable_rpm
    contain php::install_php
    contain httpd::restart
}