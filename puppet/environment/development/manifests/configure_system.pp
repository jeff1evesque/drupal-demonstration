### configure_system.pp: configures general system configurations.

## define system timezone
class { 'timezone':
    locality => 'UTC',
}