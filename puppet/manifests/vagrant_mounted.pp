## variables
$mountpoint = '/vagrant/'

## define $PATH for all execs, and packages
Exec {path => ['/usr/bin/', '/sbin/']}

## create startup script: for 'vagrant-mounted' event
file {"vagrant-startup-script":
    path    => "/etc/init/workaround-vagrant-bug-6074.conf",
    ensure  => 'present',
    content => @("EOT"),
               #!upstart
               description 'workaround for https://github.com/mitchellh/vagrant/issues/6074'

               ## start job defined in this file after system services, and processes have already loaded
               #      (to prevent conflict).
               #
               #  @filesystem, an event that fires after all filesystems have mounted
               start on filesystem

               # user:group file permission is vagrant:vagrant for entire repository
               #
               # Note: the following stanzas are not supported with current upstart 0.6.5.
               #       Specifically, upstart 1.4.x, or higher is required.
               #setuid vagrant
               #setgid vagrant

               ## block all jobs until the 'post-stop' event from this corresponding job has completed
               #     (short-lived). When the 'task' directive is absent, then all other jobs are blocked
               #     until the 'starting' event has completed (longer-lived).
               task

               ## until successful mount, sleep with 1s delay, then emit 'vagrant-mounted' event
               #
               #  @runuser, change the current user, since the above setuid, setgid stanzas
               #      are not supported, hence the below commented lines.
               #
               #  @-q, run 'mountpoint' silently
               #
               #  @--no-wait, do not wait for the emit command to finish
               #
               #  @MOUNTPOINT, specifies the environment variable to be included with the 'emit' event, where
               #      [key=value] being [MOUNTPOINT=${mountpoint}]. This allows the receiving process(es) to use
               #      the corresponding environment variable.
               script
                   sudo runuser vagrant
                   until mountpoint -q ${mountpoint}; do sleep 1; done
                   /sbin/initctl emit --no-wait vagrant-mounted MOUNTPOINT=${mountpoint}
               end script
               | EOT
               notify  => Exec["dos2unix-upstart-vagrant"],
}

## dos2unix upstart: convert clrf (windows to linux) in case host machine is windows.
exec {"dos2unix-upstart-vagrant":
    command => 'dos2unix /etc/init/workaround-vagrant-bug-6074.conf',
    notify  => Exec['workaround-vagrant-bug-6074'],
}

## start 'workaround-vagrant-bug-6074' service
#
#  Note: the 'service { ... }' stanza yields a syntax error. Therefore, the following
#        'exec { ... }' stanza has been implemented (refer to github issue #189).
exec {'workaround-vagrant-bug-6074':
    command => 'sudo initctl start workaround-vagrant-bug-6074'
}