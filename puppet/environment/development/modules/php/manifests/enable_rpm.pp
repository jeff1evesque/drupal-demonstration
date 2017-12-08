###
### Enable rpm package needed by php installation.
###

class php::enable_rpm {
    ## local variables
    $version        = '56'
    $php_repo       = '/etc/yum.repos.d/remi.repo'
    $temp_file      = '/home/provisioner/remi.tmp'
    $working_dir    = '/home/provisioner'

    ## enable php56 rpm
    exec {'enable-php-1':
        command     => "awk '/\[remi-php${version}\]/,/\[remi-test\]/ { if (/enabled=0/) \$0 = \"enabled=1\" }1' ${php_repo} > ${temp_file}",
        notify      => Exec["enable-php-2"],
        path        => '/usr/bin',
        onlyif      => "awk 'index(\$0, \"[remi-php56]\") {f=1} index(\$0, \"[remi-test]\") {exit 0} f && /enabled=1/ {exit 1}' ${php_repo}",
    }
    exec {'enable-php-2':
        command     => "mv ${working_dir}/remi.tmp /etc/yum.repos.d/remi.repo",
        refreshonly => true,
        path        => '/usr/bin',
    }
}
