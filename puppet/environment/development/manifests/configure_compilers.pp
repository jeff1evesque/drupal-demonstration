## define $PATH for all execs, and packages
Exec {path => ['/usr/bin/', '/sbin/', '/bin/', '/usr/share/']}

## variables: for webcompiler directory structure build
#
#  @asset_dir, indicate whether to create corresponding asset directory.
#
#  @src_dir, indicate whether to create corresponding source directory.
#
#  Note: hash iteration is done alphabetically.
$compilers = {
    imagemin   => {
        src   => 'img',
        asset => 'img',
        asset_dir => true,
        src_dir   => true,
    },
    sass       => {
        src       => 'scss',
        asset     => 'css',
        asset_dir => true,
        src_dir   => true,
    },
    uglifyjs   => {
        src       => 'js',
        asset     => 'js',
        asset_dir => true,
        src_dir   => true,
    }
}

## variables: general build
$build_environment = 'development'
$path_source       = '/vagrant/src'
$path_asset        = '/vagrant/webroot/sites/all/themes/custom/sample_theme/asset'

## install nodejs dependencies
class install_nodejs_dependencies {
    include stdlib
    include wget
}

## install nodejs: to use npm
class install_nodejs {
    ## set dependency
    require install_nodejs_dependencies

    class { 'nodejs':
        repo_url_suffix => '5.x',
    }
}

## install necessary packages
class install_packages {
    ## set dependency
    require install_nodejs_dependencies
    require install_nodejs

    ## variables
    $packages_general  = ['inotify-tools', 'ruby-devel']
    $packages_npm      = ['uglify-js', 'node-sass', 'imagemin']

    ## packages: install general packages (apt, yum)
    package { $packages_general:
        ensure => 'installed',
        before => Package[$packages_npm],
    }

    ## packages: install general packages (npm)
    package {$packages_npm:
        ensure => 'installed',
        provider => 'npm',
    }
}

## create necessary directories
class create_directories {
    ## set dependency
    require install_nodejs_dependencies
    require install_nodejs
    require install_packages

    ## create log directory
    file {'/vagrant/log/':
        ensure => 'directory',
        before => File[$path_source],
    }

    ## create source directory
    file {$path_source:
        ensure => 'directory',
        before => File[$path_asset],
    }

    ## create asset directory
    file {$path_asset:
        ensure => 'directory',
    }
}

## create compilers
class create_compilers {
    ## set dependency
    require install_nodejs_dependencies
    require install_nodejs
    require install_packages
    require create_directories

    ## dynamically create compilers
    $compilers.each |String $compiler, Hash $resource| {
        ## variables
        $check_files = "if [ \"$(ls -A ${path_source}/${resource['src']}/)\" ];"
        $touch_files = "then touch ${path_source}/${resource['src']}/*; fi"

        ## create asset directories (if not exist)
        if ($resource['asset_dir']) {
            file {"${path_asset}/${resource['asset']}/":
                ensure => 'directory',
                before => File["${compiler}-startup-script"],
            }
        }

        ## create src directories (if not exist)
        if ($resource['src_dir']) {
            file {"${path_source}/${resource['src']}/":
                ensure => 'directory',
                before => File["${compiler}-startup-script"],
            }
        }

        ## create systemd webcompiler service(s)
        #
        #  @("EOT"), double quotes on the end tag, allows variable interpolation within the puppet heredoc.
        file {"${compiler}-startup-script":
            path    => "/etc/systemd/system/${compiler}.service",
            ensure  => 'present',
            content => dos2unix("/vagrant/puppet/environment/${build_environment}/template/webcompilers.erb"),
            mode    => '770',
            before  => File["dos2unix-bash-${compiler}"],
        }

        ## dos2unix bash: convert clrf (windows to linux) in case host machine is windows.
        #
        #  @notify, ensure the webserver service is started. This is similar to an exec statement, where the
        #      'refreshonly => true' would be implemented on the corresponding listening end point. But, the
        #      'service' end point does not require the 'refreshonly' attribute.
        file {"dos2unix-bash-${compiler}":
            ensure  => 'present',
            content => dos2unix("/vagrant/puppet/environment/${build_environment}/scripts/${compiler}"),
            path    => "/vagrant/puppet/environment/${build_environment}/scripts/${compiler}",
            notify  => Service[$compiler],
        }

        ## start compiler service(s)
        service {$compiler:
            ensure => 'running',
            enable => true,
            notify => Exec["touch-${resource['src']}-files"],
        }

        ## touch source: ensure initial build compiles every source file.
        #
        #  @touch, changes the modification time to the current system time.
        #
        #  Note: the current inotifywait implementation watches close_write, move,
        #        and create. However, the source files will already exist before
        #        this 'inotifywait', since the '/vagrant' directory will already
        #        have been mounted on the initial build.
        #
        #  Note: every 'command' implementation checks if directory is nonempty,
        #        then touch all files in the directory, respectively.
        exec {"touch-${resource['src']}-files":
            command     => "${check_files} ${touch_files}",
            refreshonly => true,
            provider    => shell,
        }
    }
}

## constructor
class constructor {
    contain install_nodejs_dependencies
    contain install_nodejs
    contain install_packages
    contain create_directories
    contain create_compilers
}
include constructor