### configure_cache.pp: install, and configure caching for drupal.
###
### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###

## install, and configure redis
class configure_redis {
    ## install redis-server
    contain package::redis

    ## install redis-client
    contain package::predis

    ## configure, and allow httpd socket connections
    contain redis_server::configure
}

## initiate
include configure_redis