class drupal::web_stanza {
  if defined('$::sites') {
    $::sites.each |String $key, Hash $value| {
      # notice("key: ${key} - hash: ${value}")
      $site_name   = $value['site_name']
      $site_domain = "${site_name}.dev"
      file {$key:
        ensure  => 'file',
        notify  => Service['nginx'],
        content => template('drupal/nginx_stanza.erb'),
        path    => sprintf('/etc/nginx/conf.d/%s.conf', $key),
        require => Package['nginx'],
      }
    }
  }
}