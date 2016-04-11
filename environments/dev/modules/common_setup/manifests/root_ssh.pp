class common_setup::root_ssh {
  if defined('$ssh_key') {
    ssh_authorized_key { 'root':
      user => 'root',
      type => $ssh_key_type,
      key  => $ssh_key,
    }
  }
}