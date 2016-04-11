# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'pathname'
require 'socket'
require 'timeout'
require 'yaml'

# is the config file present? if not, halt execution as there is nothing to do!
config_file = 'config.yml'
raise Vagrant::Errors::VagrantError.new, "ERROR: config.yml file missing." if not Pathname(config_file).exist?

# setup settings variable, dnsserver and some defaults
$settings = YAML.load_file(config_file)
dnsServer = '8.8.8.8'

# define default values
$defaults = {
  'box'      => 'box-cutter/fedora22',
  'box_url'  => 'https://atlas.hashicorp.com/box-cutter/fedora22',
  'hostip'   => '192.168.35.12',
  'hostname' => Socket.gethostname + '.dev',
  'memory'   => '2048',
  'timezone' => 'America/Chicago',
}

# sanity checks to the yaml configuration file
def checkPlugin(pluginName)
  unless Vagrant.has_plugin?(pluginName)
    raise Vagrant::Errors::VagrantError.new, pluginName + ' plugin missing. Install it with "sudo vagr
ant plugin install ' + pluginName + '"'
  end
end

['vagrant-cachier', 'vagrant-hostsupdater', 'vagrant-triggers'].each do |plugin|
  checkPlugin(plugin)
end

# get settings value, or default if not set
def getSetting(value)
  if $settings[value] == nil && $defaults[value] == nil
    raise Vagrant::Errors::VagrantError.new, "Configuration Error: #{$setting['name']} not defined in config.yml file, setup cannot continue"
  else
    if $settings[value] != nil
      return $settings[value]
    else
      return $defaults[value]
    end
  end
end


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = getSetting('box')
  config.vm.box_url = getSetting('box_url')
  config.vm.hostname = getSetting('hostname')

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  if $settings['ports']  != nil
    $settings['ports'].each do |item|
      config.vm.network "forwarded_port", guest: item['vm'], host: item['local']
    end
  end

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network "private_network", ip: getSetting('hostip')

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder ".", "/vagrant",  :mount_options => ["dmode=777,fmode=766"]
  if $settings['shares'] != nil
    $settings['shares'].each do |item|
      config.vm.synced_folder item['local'], item['vm'], mount_options: ["dmode=777,fmode=766,uid=48,gid=48"]
    end
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
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false
 
    # Customize the amount of memory on the VM:
    vb.memory = getSetting('memory')
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end
 
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
  config.vm.provision "shell", inline: <<-SHELL
    if [ ! -f /etc/yum.repos.d/puppetlabs-pc1.repo ]; then
      sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-fedora-22.noarch.rpm
    fi
    if [ ! -d /opt/puppetlabs ]; then
      sudo dnf install -y puppet-agent
    fi
  SHELL
  config.vm.provision "puppet" do |puppet|
    puppet.environment_path = "environments"
    puppet.environment = "dev"
    # puppet.options = '--verbose --debug'
    keyfile = '~/.ssh/id_rsa.pub'.gsub('~', ENV['HOME'])
    if File.file?keyfile
      keycontents = File.open(keyfile, 'rb').read
      puppet.facter['ssh_key'] = keycontents.split(' ')[1]
      puppet.facter['ssh_key_type'] = keycontents.split(' ')[0]
    end
  end

end
