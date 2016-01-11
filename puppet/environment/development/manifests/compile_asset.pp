## include puppet modules
include stdlib

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
$packages_general  = ['inotify-tools', 'ruby-devel']
$packages_npm      = ['uglify-js', 'node-sass', 'imagemin']
$build_environment = 'development'

## packages: install general packages (apt, yum)
package {$packages_general:
    ensure => 'installed',
    before => Package[$packages_npm],
}

## packages: install general packages (npm)
package {$packages_npm:
    ensure => 'installed',
    provider => 'npm',
    before => File['/vagrant/log/'],
}

## create log directory
file {'/vagrant/log/':
    ensure => 'directory',
    before => File[$directory_systemd],
}

## create source directory
file {'/vagrant/sites/all/themes/custom/sample_theme/src/':
    ensure => 'directory',
    before => File['/vagrant/sites/all/themes/custom/sample_theme/asset/'],
}

## create asset directory
file {'/vagrant/sites/all/themes/custom/sample_theme/asset/':
    ensure => 'directory',
}

## dynamically create compilers
$compilers.each |String $compiler, Hash $resource| {
    ## variables
    $check_files = "if [ \"$(ls -A /vagrant/src/${resource['src']}/)\" ];"
    $touch_files = "then touch /vagrant/src/${resource['src']}/*; fi"

    ## create asset directories (if not exist)
    if ($resource['asset_dir']) {
        file {"/vagrant/sites/all/themes/custom/sample_theme/asset/${resource['asset']}/":
            ensure => 'directory',
            before => File["${compiler}-startup-script"],
        }
    }

    ## create src directories (if not exist)
    if ($resource['src_dir']) {
        file {"/vagrant/sites/all/themes/custom/sample_theme/src/${resource['src']}/":
            ensure => 'directory',
            before => File["${compiler}-startup-script"],
        }
    }

    ## create startup script (heredoc syntax)
    #
    #  @("EOT"), double quotes on the end tag, allows variable interpolation within the puppet heredoc.
    file {"${compiler}-startup-script":
        path    => "/etc/systemd/system/${compiler}.service",
        ensure  => 'present',
        content => @("EOT"),
                   ## Unit (optional): metadata for the unit (this entire file).
                   #
                   #  @Description (recommended), string describing the unit,
                   #      intended to show descriptive information of the unit.
                   #  @Documentation (optional), space separated lists of URI's
                   #      referencing documentation for this unit, or its
                   #      configuration.
                   #  @RequiresMountsFor (optional), adds dependencies of type
                   #      'Requires=', and 'After=' for mount units required to
                   #      access the specified path.
                   [Unit]
                   Description=define service to run corresponding bash script to compile source files
                   Documentation=https://github.com/jeff1evesque/drupal-demonstration/issues/248
                   RequiresMountsFor=/vagrant

                   ## Service (required): the service configuration.
                   #
                   #  @Type (recommended), configures the process start-up type for
                   #      this service unit. Specifically, 'simple' defines the
                   #      process configured with 'ExecStart' as the main process.
                   #  @User (optional), run service as specified user.
                   #  @Restart (optional), restart service, when the service
                   #      process exits, is killed, or a timeout is reached.
                   #  @ExecStart (optional), command to run when the unit is
                   #      started.
                   [Service]
                   Type=simple
                   User=vagrant
                   Restart=always
                   ExecStart=/vagrant/puppet/environment/${build_environment}/scripts/${compiler}
                   | EOT
               mode    => '770',
               notify  => Exec["dos2unix-systemd-${compiler}"],
        }

    ## dos2unix systemd: convert clrf (windows to linux) in case host machine is windows.
    #
    #  @notify, ensure the webserver service is started. This is similar to an exec statement, where the
    #      'refreshonly => true' would be implemented on the corresponding listening end point. But, the
    #      'service' end point does not require the 'refreshonly' attribute.
    exec {"dos2unix-systemd-${compiler}":
        command => "dos2unix /etc/systemd/system/${compiler}.service",
        notify  => Exec["dos2unix-bash-${compiler}"],
        refreshonly => true,
    }

    ## dos2unix bash: convert clrf (windows to linux) in case host machine is windows.
    #
    #  @notify, ensure the webserver service is started. This is similar to an exec statement, where the
    #      'refreshonly => true' would be implemented on the corresponding listening end point. But, the
    #      'service' end point does not require the 'refreshonly' attribute.
    exec {"dos2unix-bash-${compiler}":
        command => "dos2unix /vagrant/puppet/environment/${build_environment}/scripts/${compiler}",
        refreshonly => true,
        notify  => Service[$compiler],
    }

    ## start ${compiler} service
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