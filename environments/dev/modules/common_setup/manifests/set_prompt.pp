class common_setup::set_prompt {

  common_setup::tools::filehttp { 'set_prompt.sh':
    ensure => present,
    name => '/etc/profile.d/set_prompt.sh',
    source => 'https://raw.githubusercontent.com/aloyr/system_config_files/master/dotfiles/set_prompt.sh',
    mode => "0755",
  }

}