class common_setup::packages {
  $vim = $operatingsystem ? {
    'Fedora'  => 'vim-enhanced',
    'CentOS'  => 'vim-enhanced',
    'RedHat'  => 'vim-enhanced',
    'default' => 'vim',
  }
  package { "atop"    : ensure => installed }
  package { "iftop"   : ensure => installed }
  package { "iotop"   : ensure => installed }
  package { "iptraf"  : ensure => installed }
  package { "lshw"    : ensure => installed }
  package { "nload"   : ensure => installed }
  package { "pv"      : ensure => installed }
  package { "rsync"   : ensure => installed }
  package { "rsyslog" : ensure => installed }
  package { "sudo"    : ensure => installed }
  package { "screen"  : ensure => installed }
  package { "tcpdump" : ensure => installed }
  package { "tmux"    : ensure => installed }
  package { $vim      : ensure => installed }
  package { "wget"    : ensure => installed }
}