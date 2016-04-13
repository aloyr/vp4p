class lamp::php::packages {
  package {'php'                    : ensure => 'installed'}
  package {'php-cli'                : ensure => 'installed'}
  package {'php-common'             : ensure => 'installed'}
  package {'php-gd'                 : ensure => 'installed'}
  package {'php-mbstring'           : ensure => 'installed'}
  package {'php-mcrypt'             : ensure => 'installed'}
  package {'php-mysqlnd'            : ensure => 'installed'}
  package {'php-opcache'            : ensure => 'installed'}
  package {'php-pdo'                : ensure => 'installed'}
  package {'php-pear'               : ensure => 'installed'}
  package {'php-pear-Console-Table' : ensure => 'installed'}
  package {'php-pecl-imagick'       : ensure => 'installed'}
  package {'php-pecl-jsonc'         : ensure => 'installed'}
  package {'php-pecl-redis'         : ensure => 'installed'}
  package {'php-pecl-xdebug'        : ensure => 'installed'}
  package {'php-pecl-xhprof'        : ensure => 'installed'}
  package {'php-process'            : ensure => 'installed'}
  package {'php-xml'                : ensure => 'installed'}
}