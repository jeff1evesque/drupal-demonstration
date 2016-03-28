### cache.pp: install, configure, various caching systems.
###
### Note: the prefix 'cache::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###

## implement varnish
include cache::varnish::install
include cache::varnish::configure