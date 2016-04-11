class common_setup {
  class {'common_setup::packages': }
  class {'common_setup::root_ssh': }
  class {'common_setup::selinux_off': }
  class {'common_setup::firewall_off': }
  class {'common_setup::set_prompt': }
  common_setup::tools::dnfgroup { 'Development Tools': }
}