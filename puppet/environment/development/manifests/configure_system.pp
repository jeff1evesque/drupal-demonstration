### configure_system.pp: configures general system configurations.

## define system timezone
class { 'timezone':
    region   => 'America',
    locality => 'New_York',
}