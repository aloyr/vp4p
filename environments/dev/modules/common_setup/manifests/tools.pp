class common_setup::tools{

  # install a group of packages via dnf
  define dnfgroup($ensure = "present", $optional = false) {
    case $ensure {
      present,installed: {
        $pkg_types_arg = $optional ? {
          true => "--setopt=group_package_types=optional,default,mandatory",
          default => "installed"
        }
        exec { "Installing $name dnf group":
          command => "dnf -y groupinstall $pkg_types_arg $name",
          onlyif => "echo '! dnf grouplist \"$name\" | grep -E \"^Installed\" > /dev/null' |bash",
          timeout => 600,
        }
      }
    }
  }

  # download a file from the internet
  define filehttp($ensure = "present", $mode = "0755", $source = "/dev/null") {
    case $ensure {
      present,installed: {
        exec { "Downloading $name":
          command => "wget --no-check-certificate -O $name -q $source",
          creates => $name,
          timeout => 600,
          require => Package[ "wget" ],
        }
        if $source != "/dev/null" {
          file { $name:
            mode => $mode,
            require => Exec[ "Downloading $name" ],
          }
        }
      }
    }
  }
}