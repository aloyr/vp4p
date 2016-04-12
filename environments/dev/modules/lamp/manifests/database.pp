class lamp::database {

  package {'mariadb'        : ensure => 'installed' }
  package {'mariadb-server' : ensure => 'installed' }

  service {'mariadb':
    enable  => 'true',
    ensure  => 'running',
    require => [File['mariadb_optimizations'], Package['mariadb-server']],
  }

  file { '/var/log/mysql_slow_queries.log':
    ensure  => file,
    group   => 'mysql',
    owner   => 'mysql',
    require => File['mariadb_optimizations'],
  }

  file { 'mariadb_optimizations':
    path    => '/etc/my.cnf.d/mariadb_optimizations.cnf',
    ensure  => file,
    content => template('lamp/mariadb_optimizations.erb'),
    require => Package['mariadb-server'],
  }

}
