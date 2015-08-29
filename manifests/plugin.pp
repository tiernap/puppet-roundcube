# == Define: roundcube:plugin
#
# Install and configure the given Roundcube plugin.
#
define roundcube::plugin (
  $ensure = present,
  $config_file_template = undef,
  $options_hash = {},
) {
  include composer
  include roundcube
  require roundcube::workarounds::broken_plugin_installer

  $application_dir = $roundcube::install::target
  $config_file = $roundcube::config::config_file
  $title_array = split($title, '/')
  $system_plugin = size($title_array) == 1

  if $system_plugin {
    $plugin_name = $name
  }
  else
  {
    $plugin_name = $title_array[1]
  }

  $plugin_config_file = "${application_dir}/plugins/${plugin_name}/config.inc.php"
  $options = $options_hash

  if !$system_plugin {
    exec { "${roundcube::composer_command_name} require ${name}:${ensure} --update-no-dev --ignore-platform-reqs":
      unless      => "${roundcube::composer_command_name} show --installed ${name} ${ensure}",
      cwd         => $application_dir,
      path        => $roundcube::exec_paths,
      environment => $roundcube::composer_exec_environment,
      require     => Class['roundcube::install'],
      before      => Concat[$plugin_config_file],
    }
  }

  concat { $plugin_config_file:
    ensure => present,
    owner  => $roundcube::process,
    group  => $roundcube::process,
    mode   => '0440',
  }

  concat::fragment { "${plugin_config_file}__default_config":
    target => $plugin_config_file,
    source => "${plugin_config_file}.dist",
    order  => '10',
  }

  concat::fragment { "${plugin_config_file}__custom_config":
    target  => $plugin_config_file,
    content => template('roundcube/config/options.php.erb'),
    order   => '20',
  }

  concat::fragment { "${config_file}__plugins_${title}":
    target  => $config_file,
    content => "  '${title}',",
    order   => '55',
  }
}