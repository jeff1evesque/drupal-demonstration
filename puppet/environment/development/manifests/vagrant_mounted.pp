## variables
$mountpoint = '/vagrant/'

## define $PATH for all execs, and packages
Exec {path => ['/usr/bin/', '/sbin/']}

## create systemd script: for 'vagrant-mounted' event
file {"vagrant-systemd-script":
    path    => "/etc/systemd/service/workaround-vagrant-bug-6074.service",
    ensure  => 'present',
    content => @("EOT"),
               ## Unit (optional): metadata for the unit (this entire file).
               #
               #  @Description (recommended), string describing the unit,
               #      intended to show descriptive information of the unit.
               #  @Documentation (optional), space separated lists of URI's
               #      referencing documentation for this unit, or its
               #      configuration.
               [Unit]
               Description=emit event after shared directory is mounted
               Documentation=https://github.com/mitchellh/vagrant/issues/6074

               ## Service (required): the service configuration.
               #
               #  @Type (recommended), configures the process start-up type for
               #      this service unit. Specifically, 'idle' delays the
               #      corresponding service until all jobs have dispatched.
               #  @User (optional), run service as specified user.
               #  @ExecStart (optional), command to run when the unit is
               #      started.
               #
               #  @-q, run 'mountpoint' silently
               #  @--no-wait, do not wait for the emit command to finish
               #  @MOUNTPOINT, specifies the environment variable to be
               #      included with the 'emit' event, where [key=value] being
               #      [MOUNTPOINT=${mountpoint}]. This allows the receiving
               #      process(es) to use the corresponding environment
               #      variable.
               [Service]
               Type=idle
               User=vagrant
               ExecStart=until mountpoint -q ${mountpoint}; do sleep 1; done
               ExecStart=/sbin/initctl emit --no-wait vagrant-mounted MOUNTPOINT=${mountpoint}
               | EOT
               notify  => Exec["dos2unix-upstart-vagrant"],
}

## dos2unix upstart: convert clrf (windows to linux) in case host machine is windows.
exec {"dos2unix-upstart-vagrant":
    command => 'dos2unix /etc/init/workaround-vagrant-bug-6074.conf',
    notify => Exec['workaround-vagrant-bug-6074'],
}

## start 'workaround-vagrant-bug-6074' service
#
#  Note: the 'service { ... }' stanza yields a syntax error. Therefore, the following
#        'exec { ... }' stanza has been implemented (refer to github issue #189).
exec {'workaround-vagrant-bug-6074':
    command => "initctl start workaround-vagrant-bug-6074",
    refreshonly => true,
}