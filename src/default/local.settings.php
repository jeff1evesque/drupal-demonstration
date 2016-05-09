<?php

/**
 * Redis configuration
 */
$conf['redis_client_interface'] = 'PhpRedis'; // Can be "Predis".
$conf['redis_client_host']      = '1.2.3.4';  // Your Redis instance hostname.
$conf['lock_inc']               = 'sites/all/modules/redis/redis.lock.inc';
$conf['path_inc']               = 'sites/all/modules/redis/redis.path.inc';
$conf['cache_backends'][]       = 'sites/all/modules/redis/redis.autoload.inc';
$conf['cache_default_class']    = 'Redis_Cache';