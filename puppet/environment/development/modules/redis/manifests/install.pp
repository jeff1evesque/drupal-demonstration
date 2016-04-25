### Note: the prefix 'redis::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class redis::install {
    include redis
    class { 'redis':
        version => '2.6.5',
    }
}
