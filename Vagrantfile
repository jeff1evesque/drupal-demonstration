# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  ## Variables (ruby syntax)
  required_plugins = %w(vagrant-r10k vagrant-triggers)
  plugin_installed = false

  ## Install Vagrant Plugins
  required_plugins.each do |plugin|
    unless Vagrant.has_plugin? plugin
      system "vagrant plugin install #{plugin}"
      plugin_installed = true
    end
  end

  ## Restart Vagrant: if new plugin installed
  if plugin_installed == true
    exec "vagrant #{ARGV.join(' ')}"
  end

  ## ensure puppet/modules directory on the host before 'vagrant up'
  config.trigger.before :up do
    run 'mkdir -p puppet/environment/development/modules'
    run 'mkdir -p puppet/environment/development/modules_contrib'
  end

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = 'jeff1evesque/centos7x'
  config.vm.box_version = '1.0.0'

  ## pty used during provisioning (i.e. vagrant base box)
  config.ssh.pty = true

  ## ssh
  config.ssh.private_key_path = './centos7x/.ssh/private'
  config.ssh.username = 'provisioner'
  config.ssh.password = 'vagrant-provision'

  ## Define fully qualified domain name
  config.vm.hostname = "drupal-demonstration.com"

  ## Create a forwarded port mapping which allows access to a specific port
  #  within the machine from a port on the host machine.
  config.vm.network "forwarded_port", guest: 80, host: 6585
  config.vm.network "forwarded_port", guest: 443, host: 6686

  ## Run r10k
  config.r10k.puppet_dir = 'puppet/environment/development'
  config.r10k.puppetfile_path = 'puppet/environment/development/Puppetfile'

  ## Custom Manifest: install, and configure database
  #
  #  Note: future parser allow array iteration in the puppet manifest
  config.vm.provision "puppet" do |puppet|
    puppet.environment_path = 'puppet/environment'
    puppet.environment      = 'development'
    puppet.manifests_path   = 'puppet/environment/development/manifests'
    puppet.module_path      = 'puppet/environment/development/modules_contrib'
    puppet.manifest_file    = 'configure_database.pp'
  end

  ## Custom Manifest: general configuration
  config.vm.provision "puppet" do |puppet|
    puppet.environment_path = 'puppet/environment'
    puppet.environment      = 'development'
    puppet.manifests_path   = 'puppet/environment/development/manifests'
    puppet.module_path      = 'puppet/environment/development/modules_contrib'
    puppet.manifest_file    = 'configure_httpd.pp'
  end

  ## Custom Manifest: install, and configure php (required before drush)
  #
  #  Note: future parser allow array iteration in the puppet manifest
  config.vm.provision "puppet" do |puppet|
    puppet.environment_path = 'puppet/environment'
    puppet.environment      = 'development'
    puppet.manifests_path   = 'puppet/environment/development/manifests'
    puppet.module_path      = 'puppet/environment/development/modules_contrib'
    puppet.manifest_file    = "configure_php.pp"
  end

  ## Custom Manifest: install drush
  config.vm.provision "puppet" do |puppet|
    puppet.environment_path = 'puppet/environment'
    puppet.environment      = 'development'
    puppet.manifests_path   = 'puppet/environment/development/manifests'
    puppet.module_path      = 'puppet/environment/development/modules_contrib'
    puppet.manifest_file    = 'configure_drush.pp'
  end

  ## Custom Manifest: add sass, uglifyjs, imagemin compilers
  config.vm.provision "puppet" do |puppet|
    puppet.environment_path = 'puppet/environment'
    puppet.environment      = 'development'
    puppet.manifests_path   = 'puppet/environment/development/manifests'
    puppet.module_path      = 'puppet/environment/development/modules_contrib'
    puppet.manifest_file    = 'configure_compilers.pp'
  end

  ## Custom Manifest: install drupal
#  config.vm.provision "puppet" do |puppet|
#    puppet.environment_path = 'puppet/environment'
#    puppet.environment      = 'development'
#    puppet.manifests_path   = 'puppet/environment/development/manifests'
#    puppet.module_path      = ['puppet/environment/development/modules_contrib', 'puppet/environment/development/modules']
#    puppet.manifest_file    = 'install_drupal.pp'
#  end

  ## Custom Manifest: add redis
  config.vm.provision "puppet" do |puppet|
    puppet.environment_path = 'puppet/environment'
    puppet.environment      = 'development'
    puppet.manifests_path   = 'puppet/environment/development/manifests'
    puppet.module_path      = ['puppet/environment/development/modules_contrib', 'puppet/environment/development/modules']
    puppet.manifest_file    = 'configure_cache.pp'
  end

  ## Custom Manifest: stig centos
  config.vm.provision 'puppet' do |puppet|
    puppet.environment_path = 'puppet/environment'
    puppet.environment      = 'development'
    puppet.manifests_path   = 'puppet/environment/development/manifests'
    puppet.module_path      = ['puppet/environment/development/modules_contrib', 'puppet/environment/development/modules']
    puppet.manifest_file    = 'stig.pp'
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  ## set general project ownership, and permission
  config.vm.synced_folder './', '/vagrant',
    owner: 'provisioner',
    group: 'provisioner',
    mount_options: ['dmode=755', 'fmode=664']

  ## set build ownership, and permission
  config.vm.synced_folder './build', '/vagrant/build',
    owner: 'provisioner',
    group: 'provisioner',
    mount_options: ['dmode=755', 'fmode=700']

  ## set puppet bash script(s) ownership, and permission
  config.vm.synced_folder './puppet/environment/development/scripts', '/vagrant/puppet/environment/development/scripts',
    owner: 'provisioner',
    group: 'provisioner',
    mount_options: ['dmode=755', 'fmode=700']

  ## set permission for drupal 'settings*.php'
  config.vm.synced_folder './src/default', '/vagrant/webroot/sites/default',
    owner: 'provisioner',
    group: 'apache',
    mount_options: ['dmode=775', 'fmode=664']

  ## allow 'sites/default/files/' to be writeable for drupal install
  config.vm.synced_folder './webroot/sites/default/files', '/vagrant/webroot/sites/default/files',
    owner: 'provisioner',
    group: 'apache',
    mount_options: ['dmode=775', 'fmode=775']

  ## clean up files on the host after the guest is destroyed
  config.trigger.after :destroy do
    run 'rm -Rf log'
    run 'rm -Rf build/phpredis'
    run 'rm -Rf puppet/environment/development/modules_contrib'
    run 'rm -Rf webroot/sites/all/themes/custom/sample_theme/asset'
    run 'rm -Rf webroot/sites/default/files/!(README.md)'
    run 'rm -f webroot/sites/default/settings.php'
    run 'rm -f src/default/settings.php'
  end

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end
