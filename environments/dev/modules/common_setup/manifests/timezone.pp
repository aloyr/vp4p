class common_setup::timezone {
  file { 'adjust_timezone':
    replace => yes,
    source => "/usr/share/zoneinfo/$zonefile",
    path => "/etc/localtime",
  }
}