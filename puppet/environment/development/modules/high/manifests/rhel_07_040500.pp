### ID: rhel_07_040500
### Severity: High
###
### Description: If TFTP is required for operational support (such as the
###              transmission of router configurations) its use must be
###              documented with the ISSM, restricted to only authorized
###              personnel, and have access control rules established.
###
### Fix: Remove the TFTP package from the system with the following command:
###
###      yum remove tftp
###
### Note: the prefix 'high::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class high::rhel_07_040500 {
    ## variables
    $packages = ['tftp']

    ## remove package(s): uninstall, and remove corresponding configurations
	package { $packages:
		ensure => purged,
    }
}