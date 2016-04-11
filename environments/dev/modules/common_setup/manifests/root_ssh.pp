class common_setup::root_ssh {
  if defined('$ssh_key') {
    ssh_authorized_key { 'root':
      user => 'root',
      type => $ssh_key_type,
      key  => $ssh_key,
    }
    # file { '/root/.ssh':
    #   ensure => 'directory',
    #   owner => 'root',
    #   mode => '700',
    # }

    # file { '/root/.ssh/authorized_keys':
    #   ensure => 'file',
    #   content => $ssh_key,
    #   require => File [ '/root/.ssh' ],
    #   mode => '644'
    # }
  }
}