class common_setup::pre {

  class pre_packages {
    package {'kernel-headers' : ensure => 'installed'}
    package {'kernel-devel'   : ensure => 'installed'}
  }

  class pre_dnf_cache {
    exec {'dnf_cache':
      command => "yum makecache fast",
      timeout => 600,
    }
  }

  class pre_stage {
    class {'common_setup::selinux_off': }
    class {'common_setup::firewall_off': }
    class {'common_setup::pre::pre_dnf_cache': }
    common_setup::tools::dnfgroup { 'Development Tools': }
    class {'common_setup::pre::pre_packages': }
  }

  stage { 'pre':
    before => Stage[ 'main' ],
  }

  class { 'common_setup::pre::pre_stage':
    stage => 'pre'
  }

}