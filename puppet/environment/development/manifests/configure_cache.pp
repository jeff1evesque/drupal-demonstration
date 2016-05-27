### configure_cache.pp: install, and configure caching for drupal.
###
### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###

## install redis
class install_redis {
    ## install redis-server
    contain package::redis

    ## install php-devel: dependency to install 'phpredis'
    contain package::php_devel

    ## install phpredis
    contain package::phpredis
}

## start redis
class start_redis {
    ## set dependency
    require install_redis

    ## start redis-server
    contain redis::start
}

## initiate
include start_redis