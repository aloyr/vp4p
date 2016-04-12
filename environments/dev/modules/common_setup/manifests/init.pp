class common_setup {
  class {'common_setup::pre': }

  class {'common_setup::packages': }
  class {'common_setup::root_ssh': }
  class {'common_setup::set_prompt': }
  class {'common_setup::timezone': }
}