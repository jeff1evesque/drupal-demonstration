## create '/vagrant/sites/all/themes/contrib/' directory
file {'/vagrant/sites/all/themes/contrib/':
    ensure => 'directory',
    before => Vcsrepo['/vagrant/build/scikit-learn'],
}

## download bootstrap theme
vcsrepo {'/vagrant/sites/all/themes/contrib/bootstrap':
    ensure => present,
    provider => git,
    source => 'http://cgit.drupalcode.org/bootstrap',
    revision => '7.x-3.x',
}