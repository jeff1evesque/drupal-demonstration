### ID: rhel_07_040580
### Severity: High
###
### Description: Whether active or not, default simple network management
###              protocol (SNMP) community strings must be changed to maintain
###              security. If the service is running with the default
###              authenticators, then anyone can gather data about the system
###              and the network and use the information to potentially
###              compromise the integrity of the system or network(s). It is
###              highly recommended that SNMP version 3 user authentication and
###              message encryption be used in place of the version 2 community
###              strings.
###
### Fix: Verify that a system using SNMP is not using default community
###      strings.
###
###      Check to see if the “/etc/snmp/snmpd.conf” file exists with the
###      following command:
###
###      ls –al /etc/snmp/snmpd.conf
###      -rw-------   1 root root      52640 Mar 12 11:08 snmpd.conf
###
###      If the file does not exist, this is Not Applicable.
###
###      If the file does exist check for the default community strings with
###      the following commands:
###
###      grep public /etc/snmp/snmpd.conf
###      grep private /etc/snmp/snmpd.conf
###
###      If either of these command returns any output, this is a finding
###
### Note: the prefix 'high::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class high::rhel_07_040580 {
    ## variables
    $snmp_file = '/etc/snmp/snmpd.conf'

    ## remove public community string(s)
    exec { 'remove-multiple-protocols':
        command => "sed -i '/.*public.*$/d' ${snpm_file}",
        path    => '/usr/bin',
    }

    ## remove private community string(s)
    exec { 'remove-multiple-protocols':
        command => "sed -i '/.*private.*$/d' ${snpm_file}",
        path    => '/usr/bin',
    }
}