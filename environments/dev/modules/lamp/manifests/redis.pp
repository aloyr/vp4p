class lamp::redis {
  package {'redis': ensure => 'installed'}

  service {'redis':
    enable  => 'true',
    ensure  => 'running',
    require => Package['redis'],
  }
}