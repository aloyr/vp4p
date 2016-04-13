Exec {
  path => '/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin',
}

node 'default' {
  class {'common_setup': }->
  class {'lamp': }->
  class {'drupal': }
}
