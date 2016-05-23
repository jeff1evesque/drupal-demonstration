### Note: the prefix 'high::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class drupal::install {
    ## local variables
    $db_user     = 'root'
    $db_pass     = 'password'
    $address     = 'localhost'
    $port        = '6686'
    $db          = 'db_drupal'
    $drupal_user = 'admin'
    $drupal_pass = 'password'
    $site_name   = 'sample'
    $site_email  = 'sample.email@domain.com'
    $locale      = 'us'
    $timezone    = 'America/New York'
    $webroot     = '/vagrant/webroot'

    ## combined logical variable
    $sql = "--db-url=mysql://${db_user}/${db_pass}@${address}:${port}/${db}"
    $acc = "--account-name=${drupal_user} --account-pass=${drupal_pass}"
    $tmz = "date_default_timezone=${timezone}"

    ## install drupal
    exec { 'install-drupal':
        command => "drush site-install ${sql} ${acc} ${tmz}",
        path    => '/usr/local/bin',
        cwd     => $webroot,
    }
}
