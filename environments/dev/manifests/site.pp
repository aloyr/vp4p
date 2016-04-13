Exec {
  path => '/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin',
}

node 'default' {
  class {'common_setup': }
  class {'lamp': require => Class['common_setup'] }
  class {'drupal': }
  # $::networking[interfaces].each |String $key, Hash $value| {notice("interface: ${key}")}
  # $::sites.each |String $key, Hash $value| {notice("key: ${key} - hash: ${value}")}
  # notice("interface data: ${::networking}")
  # notice("sites data: ${::sites}")
}
