class common_setup::tools{
  define dnfgroup($ensure = "present", $optional = false) {
    case $ensure {
      present,installed: {
        $pkg_types_arg = $optional ? {
          true => "--setopt=group_package_types=optional,default,mandatory",
          default => "installed"
        }
        exec { "Installing $name dnf group":
          command => "dnf -y groupinstall $pkg_types_arg $name",
          onlyif => "echo '! dnf grouplist $name | grep -E \"^Installed\" > /dev/null' |bash",
          timeout => 600,
        }
      }
    }
  }
}