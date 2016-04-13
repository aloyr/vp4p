class lamp::php {
  class {'lamp::php::packages': }
  class {'lamp::php::ini_fix'        : require => Package['php']}
  class {'lamp::php::pecl_prep'      : require => Package[['php', 'mariadb-server']]}
  class {'lamp::php::uploadprogress' : require => Package[['php', 'mariadb-server']]}
  class {'lamp::php::xdebug'         : require => Package[['php', 'mariadb-server']]}
}