class common_setup::firewall_off {
  $firewall = [ 'iptables', 'ip6tables' ]
  service { $firewall:
    ensure => stopped,
    enable => false,
  }
}