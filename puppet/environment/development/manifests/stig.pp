class stig {
    case $operatingsystem
    {
        'RedHat', 'CentOS':
        {
            #############################################################################
            #                                                                           #
            #       Redhat Enterprise 7                                                 #
            #       Severity: High                                                      #
            #                                                                           #
            #       http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx         #
            #                                                                           #
            #############################################################################

            ### rhel_07_020220:	The x86 Ctrl-Alt-Delete key sequence must be disabled.
            include high::rhel_07_020220

            ### rhel_07_010270: The SSH daemon must not allow authentication using an empty password.
            include high::rhel_07_010270

            #############################################################################
            #                                                                           #
            #       Redhat Enterprise 7                                                 #
            #       Severity: Medium                                                    #
            #                                                                           #
            #       http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx         #
            #                                                                           #
            #############################################################################

            #############################################################################
            #                                                                           #
            #       Redhat Enterprise 7                                                 #
            #       Severity: Low                                                       #
            #                                                                           #
            #       http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx         #
            #                                                                           #
            #############################################################################
        }
    }
}

## constructor
class constructor {
    contain stig
}
include constructor