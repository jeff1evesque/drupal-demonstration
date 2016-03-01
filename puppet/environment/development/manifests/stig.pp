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