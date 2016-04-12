class lamp::php {
  class {'lamp::php_packages': }
  class {'lamp::php_ini_fix'        : require => Package['php']}
  class {'lamp::php_pecl_prep'      : require => Package[['php', 'mariadb-server']]}
  class {'lamp::php_uploadprogress' : require => Package[['php', 'mariadb-server']]}
  class {'lamp::php_xdebug'         : require => Package[['php', 'mariadb-server']]}
}