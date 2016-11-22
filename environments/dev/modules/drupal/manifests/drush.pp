class drupal::drush {
  exec { 'drush_install':
    command => 'wget https://s3.amazonaws.com/files.drush.org/drush.phar -O /tmp/drush && \\
                chmod +x /tmp/drush && \\
                mv /tmp/drush /usr/local/bin',
    creates => '/usr/local/bin/drush',
  }
}