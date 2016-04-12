class lamp::php_pecl_prep {
  package {'mariadb-devel' : ensure => 'installed'}
  package {'mariadb-libs'  : ensure => 'installed'}
  package {'php-devel'     : ensure => 'installed'}
  package {'re2c'          : ensure => 'installed'}
}