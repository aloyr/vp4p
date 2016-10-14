class drupal::database {
  if defined('$::sites') {
    parsejson($::sites).each |String $key, Hash $value| {

      if has_key($value, 'database') {
        $db = $value['database']
        notice($db)
        $site_name = $value['site_name']

        exec {"database_create_${site_name}":
          command => "echo 'create database $site_name' | mysql",
          require => [Service['mariadb'], Package['mariadb']],
          unless  => "echo 'use $site_name' | mysql -BN 2> /dev/null",
        }

        exec {"database_user_${site_name}":
          command => "echo 'grant all on $site_name.* to $site_name@localhost identified by \"$site_name\"' | mysql",
          require => Exec["database_create_${site_name}"],
          unless  => "echo 'select user from mysql.user where host = \"localhost\" and user = \"$site_name\"' | mysql -BN | grep $site_name &> /dev/null",
        }

        exec {"database_user_external_${site_name}":
          command => "echo 'grant all on $site_name.* to $site_name@`%` identified by \"$site_name\"' | mysql",
          require => Exec["database_create_${site_name}"],
          unless  => "echo 'select user from mysql.user where host = \"%\" and user = \"$site_name\"' | mysql -BN | grep $site_name &> /dev/null",
        }

        exec {"database_initial_setup_${site_name}":
          command => "mysql $site_name < $db",
          require => Exec["database_user_${site_name}"],
          unless  => "[ $(echo 'show tables' | mysql -BN ${site_name} | wc -l) -gt 0 ]"
        }

      }
    }
  }
}