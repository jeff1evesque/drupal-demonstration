<?php

/**
 * Redis configuration
 */
$conf['redis_client_interface'] = 'Predis'; // Can be "Predis".
$conf['redis_client_host']      = 'localhost';
$conf['redis_client_port']      = 6379;
$conf['lock_inc']               = 'sites/all/modules/redis/redis.lock.inc';
$conf['path_inc']               = 'sites/all/modules/redis/redis.path.inc';
$conf['cache_backends'][]       = 'sites/all/modules/redis/redis.autoload.inc';
$conf['cache_default_class']    = 'Redis_Cache';