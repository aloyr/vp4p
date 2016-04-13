class lamp::php::xdebug {
  exec { 'xdebug_setup':
    command => 'echo "xdebug.remote_enable=1" >> /etc/php.d/15-xdebug.ini ; \
          echo "xdebug.remote_connect_back=1" >> /etc/php.d/15-xdebug.ini ; \
          echo "xdebug.remote_port=9000" >> /etc/php.d/15-xdebug.ini ; \
          echo "xdebug.remote_autostart=1" >> /etc/php.d/15-xdebug.ini; \
          echo "xdebug.max_nesting_level=500" >> /etc/php.d/15-xdebug.ini;',
    unless => 'grep "remote_enable" /etc/php.d/15-xdebug.ini',
    require => Package['php', 'php-pecl-xdebug' ],
  }
}