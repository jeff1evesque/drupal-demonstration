### ID: rhel-07-020000
### Severity: High
###
### Description: It is detrimental for operating systems to provide, or install
###              by default, functionality exceeding requirements or mission
###              objectives. These unnecessary capabilities or services are
###              often overlooked and therefore may remain unsecured. They
###              increase the risk to the platform by providing additional
###              attack vectors.
###
###              Operating systems are capable of providing a wide variety of
###              functions and services. Some of the functions and services,
###              provided by default, may not be necessary to support essential
###              organizational operations (e.g., key missions, functions).
###
###              Examples of non-essential capabilities include, but are not
###              limited to, games, software packages, tools, and demonstration
###              software, not related to requirements or providing a wide
###              array of functionality not required for every mission, but
###              which cannot be disabled.
###
### Fix: Configure the operating system to disable non-essential capabilities
###      by removing the rsh-server package from the system with the following
###      command:
###
###      yum remove rsh-server
###
### Note: the prefix 'high::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###	
class high::rhel_07_020000 {
    ## variables
    $packages = ['rexecd', 'rlogind', 'rsh-server']

    ## remove package(s): uninstall, and remove corresponding configurations
	package { $packages:
		ensure => purged,
    }
}