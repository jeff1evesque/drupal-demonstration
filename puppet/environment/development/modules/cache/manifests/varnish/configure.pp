### Note: the prefix 'cache::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class cache::varnish::configure {
    ## variables
    $template = 'cache/files/default.vcl'

    ## configure vcl
    varnish::vcl { '/etc/varnish/default.vcl':
        content => file(dos2unix($template)),
    }
}