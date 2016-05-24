### Note: the prefix 'high::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class drupal::install {
    ## local variables
    $db_user         = 'root'
    $db_pass         = 'password'
    $address         = 'localhost'
    $port            = '6686'
    $db              = 'db_drupal'
    $drupal_user     = 'admin'
    $drupal_pass     = 'password'
    $site_name       = 'sample'
    $site_email      = 'sample.email@domain.com'
    $locale_val      = 'us'
    $install_profile = 'sample'
    $webroot         = '/vagrant/webroot'

    ## combined variables
    $sql    = "--db-url=mysql://${db_user}:${db_pass}@${address}:${port}/${db}"
    $acc    = "--account-name=${drupal_user} --account-pass=${drupal_pass}"
    $info   = "--site-name=${site_name} --site-mail=${site_email}"
    $locale = "--locale=${locale_val}"

    ## combined arguments
    $arguments = "${install_profile} ${sql} ${acc} ${info} ${locale}"

    ## install drupal
    exec { 'install-drupal':
        command => "drush site-install $arguments -y",
        path    => ['/usr/local/bin', '/usr/bin/'],
        cwd     => $webroot,
    }
}
