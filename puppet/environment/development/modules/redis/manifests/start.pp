### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class redis::start {
    ## local variables
    $root     = 'root'
    $log_file = "${root}/vagrant/log/redis_server.log"

    ## background process writes stderr to stdout, and stdout to log
    exec { 'start-redis':
        command => 'redis-server >> ${log_file} 2>&1 &',
        path    => '/usr/local/bin',
    }
}
