## include puppet modules
include stdlib

## define $PATH for all execs, and packages
Exec {path => ['/usr/bin/', '/sbin/', '/bin/', '/usr/share/']}

## variables: the order of the following array variables are important
$compilers         = ['uglifyjs', 'sass', 'imagemin']
$directory_src     = ['js', 'scss', 'img']
$directory_asset   = ['js', 'css', 'img']
$packages_npm      = ['uglify-js', 'node-sass', 'imagemin']

## variables: the order of the following array variables are not important
$packages_general  = ['inotify-tools', 'ruby-devel']
$directory_systemd = ['/etc/', '/etc/systemd/', '/etc/systemd/vagrant/']

## variables
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

## create directory to store systemd scripts
file {$directory_systemd:
    ensure => 'directory',
    before => File['/vagrant/sites/all/themes/custom/sample_theme/src/'],
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
$compilers.each |Integer $index, String $compiler| {
    ## create source directories
    file {"/vagrant/sites/all/themes/custom/sample_theme/src/${directory_src[$index]}/":
        ensure => 'directory',
        before => File["/vagrant/sites/all/themes/custom/sample_theme/asset/${directory_asset[$index]}/"],
        require => File['/vagrant/sites/all/themes/custom/sample_theme/src/'],
    }

    ## create asset directories
    file {"/vagrant/sites/all/themes/custom/sample_theme/asset/${directory_asset[$index]}/":
        ensure => 'directory',
        before => File["${compiler}-startup-script"],
        require => File['/vagrant/sites/all/themes/custom/sample_theme/asset/'],
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
                   #      this service unit. Specifically, 'forking' runs the
                   #      corresponding service in the background.
                   #  @User (optional), run service as specified user.
                   #  @Restart (optional), restart service, when the service
                   #      process exits, is killed, or a timeout is reached.
                   #  @ExecStart (optional), command to run when the unit is
                   #      started.
                   #
                   #  @[`date`], current date script executed
                   [Service]
                   Type=forking
                   User=vagrant
                   ExecStart=/usr/bin/bash -c '/vagrant/puppet/scripts/${compiler}'
                   | EOT
               mode    => '770',
               notify  => Exec["dos2unix-upstart-${compiler}"],
        }

    ## dos2unix upstart: convert clrf (windows to linux) in case host machine is windows.
    #
    #  @notify, ensure the webserver service is started. This is similar to an exec statement, where the
    #      'refreshonly => true' would be implemented on the corresponding listening end point. But, the
    #      'service' end point does not require the 'refreshonly' attribute.
    exec {"dos2unix-upstart-${compiler}":
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
        command => "dos2unix /vagrant/puppet/environment/${environment}/scripts/${compiler}",
        refreshonly => true,
        notify  => Exec["${compiler}"],
    }

    ## start ${compiler} service
    #
    #  Note: the 'service { ... }' stanza does not start the system service.
    #        Therefore, the following 'exec { ... }' stanza has been
    #        implemented (refer to github issue #189).
    exec {"${compiler}":
        command => "systemctl enable ${compiler}",
        refreshonly => true,
        notify  => Exec["touch-${directory_src[$index]}-files"],
    }

    ## touch source: ensure initial build compiles every source file.
    #
    #  @touch, changes the modification time to the current system time.
    #
    #  Note: the current inotifywait implementation watches close_write, move, and create. However, the
    #        source files will already exist before this 'inotifywait', since the '/vagrant' directory
    #        will already have been mounted on the initial build.
    #
    #  Note: every 'command' implementation checks if directory is nonempty, then touch all files in the
	#        directory, respectively.
    exec {"touch-${directory_src[$index]}-files":
        command => "if [ `ls -A /vagrant/sites/all/themes/custom/sample_theme/src/${directory_src[$index]}/` ]; then touch /vagrant/sites/all/themes/custom/sample_theme/src/${directory_src[$index]}/*; fi",
        refreshonly => true,
        provider => shell,
    }
}