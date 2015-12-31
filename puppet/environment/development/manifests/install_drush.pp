## include puppet modules
include wget

## variables
$drush_version = '8.0.0-rc4'

## download drush: wget is a wrapper around the 'exec' function
#
#  @timeout, override the default 'exec' timeout
#  @verbose, verbose logging
wget::fetch {'download-drush':
  source      => "https://github.com/drush-ops/drush/releases/download/${drush_version}/drush.phar",
  destination => '/tmp/drush.phar',
  timeout     => 0,
  verbose     => false,
  notify      => Exec['test-drush-install']
}

## test drush install
exec {'test-drush-install':
  command     => 'php drush.phar core-status',
  cwd         => '/tmp',
  refreshonly => true,
  notify      => Exec['change-permission-drush'],
}

## change permission for 'drush.phar'
exec {'change-permission-drush':
  command     => 'chmod +x drush.phar',
  refreshonly => true,
  notify      => Exec['move-drush'],
}

## move drush anywhere on $PATH, as 'drush', instead of 'drush.phar'
exec {'move-drush':
  command     => 'mv drush.phar /usr/local/bin/drush',
  refreshonly => true,
  notify      => Exec['initialize-drush'],
}

## enrich the bash startup file with completion and aliases
exec {'initialize-drush':
  command     => 'drush init',
  refreshonly => true,
}