### ID: rhel_07_020010
### Severity: High
###
### Description: Removing the "ypserv" package decreases the risk of the
###              accidental (or intentional) activation of NIS or NIS+
###              services.
###
### Fix: Configure the operating system to disable non-essential capabilities
###      by removing the “ypserv” package from the system  with the following
###      command:
###
###      yum remove ypserv
###
### Note: the prefix 'high::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###	
class high::rhel_07_020010 {
    ## variables
    $packages = ['ypserv']

    ## remove package(s): uninstall, and remove corresponding configurations
	package { $packages:
		ensure => purged,
    }
}