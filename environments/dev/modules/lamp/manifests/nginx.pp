class lamp::nginx {

  package {'nginx':
    ensure  => 'installed',
    require => Package['php-fpm'],
  }

  package {'php-fpm':
    ensure  => 'installed',
    require => Package['php'],
  }

  service {'nginx':
    enable  => 'true',
    ensure  => 'running',
    require => Package['nginx'],
  }
}