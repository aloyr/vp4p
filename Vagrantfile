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

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = getSetting('box')
  config.vm.box_url = getSetting('box_url')
  config.vm.hostname = getSetting('hostname')
  sites = getSites()
  config.hostsupdater.aliases = $settings['aliases']

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
      if item['type'] != nil && item['type'] == 'rsync'
        config.vm.synced_folder item['local'].gsub('~', ENV['HOME']), item['vm'], owner: 'nginx', group: 'nginx', type: 'rsync', rsync__auto: true
      else
        config.vm.synced_folder item['local'].gsub('~', ENV['HOME']), item['vm'], owner: 'nginx', group: 'nginx'
      end
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
    # puppet.options = '--verbose --debug'
    # puppet.structured_facts = true
    puppet.environment_path = "environments"
    puppet.environment = "dev"
    keyfile = '~/.ssh/id_rsa.pub'.gsub('~', ENV['HOME'])
    if File.file?keyfile
      keycontents = File.open(keyfile, 'rb').read

      puppet.facter['vagrant']        = 1
      puppet.facter['database_cache'] = getSetting('database_cache')
      puppet.facter['database_pool']  = getSetting('database_pool')
      puppet.facter['ssh_key']        = keycontents.split(' ')[1]
      puppet.facter['ssh_key_type']   = keycontents.split(' ')[0]
      puppet.facter['zonefile']       = getSetting('timezone')
      puppet.facter['sites']          = sites.to_json
   end
  end

  # provisioning build triggers below
  vagstring = ' ## vagrant-provisioner' + "\n"
  config.trigger.before [:provision, :up, :resume] do
    puts 'Running before provision triggers'
    sites.each do |site|
      adjustSettingsFile site[1], vagstring
      adjustDrushAliasFile site[1], vagstring
    end
    puts 'Synching changed files'
    `vagrant rsync`
  end

  # provisioning teardown triggers below
  config.trigger.before [:destroy, :halt, :suspend] do
    puts 'Running before destroy triggers'
    sites.each do |site|
      resetSettingsFile site[1], vagstring
      resetDrushAliasFile site[1], vagstring
    end
    puts 'Synching changed files'
    `vagrant rsync`
  end

end
# End of Vagrantfile setup

# Begin custom code

# make sure we are on the correct folder before proceeding
Dir.chdir(File.dirname(__FILE__))

require 'json'
require 'pathname'
require 'socket'
require 'timeout'
require 'yaml'

# implements input with prompt
def gets_timeout( prompt, secs )
  puts
  print prompt + "[timeout=#{secs}secs]: "
  Timeout::timeout( secs ) { STDIN.gets }
rescue Timeout::Error
  puts "*timeout"
  nil  # return nil if timeout
end

# is the config file present? if not, halt execution as there is nothing to do!
config_file = 'config.yml'
raise Vagrant::Errors::VagrantError.new, "ERROR: config.yml file missing." if not Pathname(config_file).exist?

# setup settings variable and some defaults
$settings = YAML.load_file(config_file)

# define default values
$defaults = {
  'box'            => 'vp4p/fedora22',
  'box_url'        => 'http://hid.gl/vp4p-fedora22.box',
  'database_cache' => '128M',
  'database_pool'  => '1G',
  'hostip'         => '192.168.35.12',
  'hostname'       => Socket.gethostname + '.dev',
  'memory'         => '2048',
  'timezone'       => 'America/Chicago',
}

# sanity checks to the yaml configuration file
def checkPlugin(pluginName)
  unless Vagrant.has_plugin?(pluginName)
    raise Vagrant::Errors::VagrantError.new, pluginName + ' plugin missing. Install it with "sudo vagrant plugin install ' + pluginName + '"'
  end
end

# make sure we have the necessary plugins installed
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

# reset drush alias file
def resetDrushAliasFile settings, vagstring
  settingsfile = '~/.drush/vagrant.aliases.drushrc.php'.gsub('~', ENV['HOME'])
  removeString = vagstring.gsub("\n",'') + '-' + settings['site_name']
  if File.file?settingsfile
    tagstring = vagstring.gsub("\n",'') + "-" + settings['site_name'] + "\n"
    puts 'Restoring drush alias file for ' + settings['site_name']
    File.chmod(0666, settingsfile)
    settingslines = File.open(settingsfile,'r').readlines()
    writefile = File.open(settingsfile,'w+')
    settingslines.each do |line|
      writefile.write(line) if line !~ /#{tagstring}/
    end
    writefile.close()
  end
end

# add vagrant aliases to drush
def adjustDrushAliasFile settings, vagstring
  resetDrushAliasFile settings, vagstring
  puts 'Adjusting drush alias file for ' + settings['site_name']
  settingsfile = '~/.drush/vagrant.aliases.drushrc.php'.gsub('~', ENV['HOME'])
  if not File.file?settingsfile
    File.open(settingsfile, 'w+') do |writefile|
      writefile.puts '<?php'
    end
  end
  File.chmod(0666, settingsfile)
  if settings['site_name'] != nil
    tagstring = vagstring.gsub("\n",'') + "-" + settings['site_name'] + "\n"
    File.open(settingsfile,'a+') do |writefile|
      writefile.puts "$aliases['#{settings['site_name']}'] = array(              #{tagstring}"
      writefile.puts "  'root'         => '/var/www/#{settings['site_name']}',   #{tagstring}"
      writefile.puts "  'uri'          => 'http://#{settings['site_name']}.dev', #{tagstring}"
      writefile.puts "  'remote-host'  => '#{settings['site_name']}.dev',        #{tagstring}"
      writefile.puts ");                                                         #{tagstring}"
    end
  end
end

# resets settings.php file for a site
def resetSettingsFile settings, vagstring
  settingsfile = settings['site_root_local'].gsub('~', ENV['HOME']) + '/sites/default/settings.php'
  removeString = vagstring.gsub("\n",'')
  if File.file?settingsfile
    puts 'Restoring settings.php file'
    File.chmod(0666, settingsfile)
    settingslines = File.open(settingsfile,'r').readlines()
    writefile = File.open(settingsfile,'w+')
    settingslines.each do |line|
      writefile.write(line) if line !~ /#{removeString}/
    end
    writefile.close()
  end
end

# adjusts settings.php file for a site
def adjustSettingsFile settings, vagstring
  settingsfile = settings['site_root_local'].gsub('~', ENV['HOME']) + '/sites/default/settings.php'
  if not File.file?settingsfile
    defsettingsfile = settings['site_root_local'].gsub('~', ENV['HOME']) + '/sites/default/default.settings.php'
    FileUtils.cp(defsettingsfile, settingsfile)
  else
    resetSettingsFile settings, vagstring
  end
  puts 'Adjusting settings.php file'
  File.chmod(0666, settingsfile)
  settingslines = File.open(settingsfile,'r').readlines()
  writefile = File.open(settingsfile,'w+')
  settingslines.each do |line|
    writefile.write(line) if line !~ /#{vagstring}/
  end
  if settings['settings_php'] != nil
    settings['settings_php'].each do |settingline|
      writefile.write(settingline.gsub('USER', ENV['USER'].upcase) + vagstring)
    end
  end
  defaultDB = "$databases['default']['default'] = array("
  defaultDB += "'driver' => 'mysql',"
  defaultDB += "'database' => '" + settings['site_name'] + "',"
  defaultDB += "'username' => '" + settings['site_name'] + "',"
  defaultDB += "'password' => '" + settings['site_name'] + "',"
  defaultDB += "'host' => '127.0.0.1',"
  defaultDB += "'prefix' => '',"
  defaultDB += ");" + vagstring
  writefile.write(defaultDB)
  if settings['languages'] != nil
    settings['languages'].each do |lang|
      line = "$conf['language_domains']['#{lang}'] = 'http://#{lang}.#{settings['site_name']}.dev'; #{vagstring}"
      writefile.write(line)
    end
  end 
  writefile.close()
end

# process site configurations
def getSites()
  sites = {}
  # read configuration files from sites.d folder
  Dir.glob('sites.d/*yml').each do |site_file|
    site_data = YAML.load_file(site_file)
    site_name = site_data['site_name'].downcase.gsub(/[^a-zA-Z0-9]+/, '-')
    # check if the site defines a database
    # if so, import it into mariadb
    if site_data['database'] != nil
      site_data['database'] = site_data['database'].gsub(/~/, ENV['HOME'])
      if !File.exist? site_data['database']
        raise Vagrant::Errors::VagrantError.new, "Configuration Error: database file '#{site_data['database']}' defined, but not found for site '#{site_name}'"
      else
        if site_data['database'] != 'data/' + site_name + '.sql'
          FileUtils.cp site_data['database'], 'data/' + site_name + '.sql'
        end
        site_data['database'] = '/vagrant/data/' + site_name + '.sql'
        if ARGV.grep(/provision/).length > 0
          puts 'If this is the first run, just wait or press <enter>.'
          redodb = gets_timeout('Refresh database for ' + site_name + '? [y/N]', 3)
          if redodb == 'Y' || redodb == 'y'
            site_data['database_refresh'] = true
          end
        end
      end
    end
    # prepare site data
    site_data['site_name'] = site_name
    site_domain = site_name + '.dev'
    site_aliases = [site_domain, 'www.' + site_domain]
    # handle languages, if defined
    if site_data['languages'] != nil
      site_data['languages'].each do |language|
        site_aliases.concat([language + '.' + site_domain])
      end
    end
    # handle aliases, if defined
    if $settings['aliases'] == nil
      $settings['aliases'] = []
    end
    $settings['aliases'].concat(site_aliases)
    # handle shared folders, if defined
    if site_data['site_root_local'] != nil
      if $settings['shares'] == nil
        $settings['shares'] = []
      end
      folder = {
        'local' => site_data['site_root_local'],
        'vm'    => '/var/www/' + site_name
      }
      if site_data['site_root_type'] != nil
        folder['type'] = site_data['site_root_type']
      end
      $settings['shares'].push(folder)
    end
    # add current site data to overall site array
    # before looping to the next site configuration file
    site_data['site_aliases'] = site_aliases.join(' ')
    sites[site_name] = site_data
  end
  return sites
end
