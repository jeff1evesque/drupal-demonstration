### ID: rhel_07_020220
### Severity: High
###
### Description: A locally logged-in user who presses Ctrl-Alt-Delete, when at
###              the console, can reboot the system. If accidentally pressed,
###              as could happen in the case of mixed OS environment, this can
###              create the risk of short-term loss of availability of systems
###              due to unintentional reboot. In the GNOME graphical
###              environment, risk of unintentional reboot from the
###              Ctrl-Alt-Delete sequence is reduced because the user will be
###              prompted before any action is taken.
###
### Fix: To ensure the system is configured to log a message instead of
###      rebooting the system when Ctrl-Alt-Delete is pressed, ensure the
###      following line is in '/etc/init/control-alt-delete.override':
###
###      exec /usr/bin/logger -p security.info "Control-Alt-Delete pressed"
###
### Note: the prefix 'high::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class high::rhel_07_020220 {
    ## allow 'file_line' directive
    include stdlib

    ## ensure directory
    file { '/etc/init':
        ensure => directory,
        mode   => '755',
        owner  => root,
        group  => root,
        before => File['/etc/init/control-alt-delete.conf.conf'],
    }

    ## ensure permission, and ownership
    file { '/etc/init/control-alt-delete.conf.conf':
        ensure => file,
        mode   => '640',
        owner  => root,
        group  => root,
        before => File_line['prevent-ctrl-alt-delete'],
    }

    ## ensure line
    file_line { 'prevent-ctrl-alt-delete':
        path => '/etc/init/control-alt-delete.conf.conf',
        line => 'exec /usr/bin/logger -p security.info "Control-Alt-Delete pressed"',
    }
}