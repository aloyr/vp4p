class lamp::php_uploadprogress {
  exec { 'uploadprogress_setup':
    command => 'pecl install uploadprogress ; echo "extension=uploadprogress.so" > /etc/php.d/uploadprogress.ini',
    creates => '/etc/php.d/uploadprogress.ini',
    require => Package['php', 'php-pear', 'php-devel'],
  }
}