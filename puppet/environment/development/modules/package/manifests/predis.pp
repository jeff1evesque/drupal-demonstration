### Note: the prefix 'package::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class package::predis {
    ## include necessary modules
    require git

    ## local variables
    $root = '/vagrant'
    $cwd  = "${root}/webroot/sites/all/libraries/predis"

    ## download predis
    vcsrepo { $cwd:
        ensure   => present,
        provider => git,
        source   => 'https://github.com/nrk/predis',
        revision => 'v1.0.3',
    }
}
