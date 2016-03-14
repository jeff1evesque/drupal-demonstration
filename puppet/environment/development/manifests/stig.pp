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

            ### rhel_07_040590: The SSH daemon must be configured to only use the SSHv2 protocol.
            include high::rhel_07_040590

            ### rhel_07_040580: SNMP community strings must be changed from the default.
            include high::rhel_07_040580

            ### rhel_07_040500: The TFTP server package must not be installed if not required for operational support.
            include high::rhel_07_040500

            ### rhel_07_040330: There must be no .rhosts, .shosts, rhosts.equiv, or shosts.equiv files on the system.
            include high::rhel_07_040330

            ### high::rhel_07_021910: The telnet-server package must not be installed.
            include high::rhel_07_021910

            ### rhel_07_020930: All shell files must have mode 0755 or less permissive.
            include high::rhel_07_020930

            ### rhel_07_020220:	The x86 Ctrl-Alt-Delete key sequence must be disabled.
            include high::rhel_07_020220

            ### rhel_07_020010: The ypserv package must not be installed.
            include high::rhel_07_020010

            ### rhel-07-020000: The rsh-server package including rexecd and rlogind must not be installed.
            include high::rhel_07_020000

            ### rhel_07_010270: The SSH daemon must not allow authentication using an empty password.
            include high::rhel_07_010270

            ### rhel_07_010260: The system must not have accounts configured with blank or null passwords.
            include high::rhel_07_010260

            #############################################################################
            #                                                                           #
            #       Redhat Enterprise 7                                                 #
            #       Severity: Medium                                                    #
            #                                                                           #
            #       http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx         #
            #                                                                           #
            #############################################################################

            ### rhel_07_010440: The operating system must not allow an unattended or automatic remote logon to the system.
            include medium::rhel_07_010440

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