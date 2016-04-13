class lamp::php::ini_fix {
  exec { 'php_ini':
    command => "sed -i \\
            -e 's/^\\(allow_url_fopen\\) = Off/\\1 = On/g' \\
            -e 's/^; *\\(date.timezone\\) =.*/\\1 = America\\/Chicago/g' \\
            -e 's/^\\(display.*_errors\\) = Off/\\1 = On/g' \\
            -e 's/^\\(error_reporting\\) = .*/\\1 = E_ALL | E_STRICT/g' \\
            -e 's/^\\(html_errors\\) = Off/\\1 = On/g' \\
            -e 's/^\\(log_errors\\) = Off/\\1 = On/g' \\
            -e 's/^\\(memory_limit\\) = [0-9]\\+M/\\1 = 2048M/g' \\
            -e 's/^\\(post_max_size\\) = [0-9]\\+M/\\1 = 80M/g' \\
            -e 's/^\\(track_errors\\) = Off/\\1 = On/g' \\
            -e 's/^\\(upload_max_filesize\\) = [0-9]\\+M/\\1 = 20M/g' \\
            -e 's/^\\(max_execution_time\\) = [0-9]\\+/\\1 = 300/g' \\
            /etc/php.ini",
    unless => 'grep "^memory_limit = 2048M" /etc/php.ini',
    require => Package['php'],
  }
}