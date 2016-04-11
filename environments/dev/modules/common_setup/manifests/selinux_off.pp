class common_setup::selinux_off {
  exec { 'selinux-off-1':
    command => "sed -i 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config",
    onlyif => "echo '! grep -E \"^SELINUX=disabled$\" < /etc/selinux/config > /dev/null' | bash",
  }

  exec { 'selinux-off-2':
    command => "setenforce 0",
    onlyif => "sestatus |grep -E \"enforcing\" > /dev/null",
  }
}