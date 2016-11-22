class drupal {
  class {'drupal::drush': }
  class {'drupal::web_stanza': }
  class {'drupal::database': }
}