### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class package::redis {
    class { 'redis::install':
        redis_version => '3.2.0',
    }
}
