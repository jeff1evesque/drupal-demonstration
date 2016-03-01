### ID: rhel_07_040330
### Severity: High
###
### Description: The .rhosts, .shosts, rhosts.equiv, and shosts.equiv files are
###              used to configure host-based authentication for individual
###              users or the system.  Host-based authentication is not
###              sufficient for preventing unauthorized access to the system as
###              it does not require interactive identification and
###              authentication of a connection request, or for the use of two-
###              factor authentication.
###
### Fix: Remove any found .rhosts, .shosts, rhosts.equiv, or shosts.equiv files
###      from the system.
###
### Note: the prefix 'high::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class high::rhel_07_040330 {
	tidy { 'delete-rhosts':
        path    => '/',
        recurse => true,
        matches => ['*.rhosts', '*.shosts', 'rhosts.equiv', 'shosts.equiv'],
	}
}