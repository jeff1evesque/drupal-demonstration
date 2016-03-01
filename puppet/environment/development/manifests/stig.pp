class stig {
	case $operatingsystem 
	{
		redhat:
		{
            #############################################################################
			#                                                                           #
			#       Centos 7x                                                           #
			#       Severity: High                                                      #
            #                                                                           #
			#       http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx         #                                                    #
			#                                                                           #
			#############################################################################

			#############################################################################
			#                                                                           #
			#       Centos 7x                                                           #
			#       Severity: Medium                                                    #
            #                                                                           #
			#       http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx         #                                                    #
			#                                                                           #
			#############################################################################

			#############################################################################
			#                                                                           #
			#       Centos 7x                                                           #
			#       Severity: Low                                                       #
            #                                                                           #
			#       http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx         #                                                    #
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