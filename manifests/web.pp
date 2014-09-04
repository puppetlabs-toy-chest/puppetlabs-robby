class robby::web(
  $port,
  $ssl_port,
  $ssl,
  $ssl_cert_path,
  $ssl_key_path,
  $run_as_user
) {

  class { '::apache':
    default_vhost => false,
  }

  class { 'apache::mod::passenger':
    passenger_root              => '/var/lib/gems/1.9.1/gems/passenger-4.0.45',
    passenger_ruby              => '/usr/bin/ruby1.9.1',
    passenger_conf_package_file => 'buildout/apache2/mod_passenger.so',
  }

  if $ssl {
    apache::vhost { 'robby-ssl':
      port        => $ssl_port,
      docroot     => "${robby::robby_path}/public",
      directories => [
        { path              => "${robby::robby_path}/public",
          passenger_enabled => 'on',
        },
      ],
      ssl         => $ssl,
      ssl_cert    => $ssl_cert_path,
      ssl_key     => $ssl_key_path
    }
  }

  apache::vhost { 'robby':
    port        => $port,
    docroot     => "${robby::robby_path}/public",
    directories => [
      { path              => "${robby::robby_path}/public",
        passenger_enabled => 'on',
      },
    ],
  }

  file { ["${robby::robby_path}","${robby::robby_path}/public"]:
    ensure => directory,
  }

  file { "${robby::robby_path}/config.ru":
    owner   => $run_as_user,
    notify  => Class['::apache::service'],
  }

  file { "${robby::robby_path}/guess_results":
    ensure => directory,
    owner  => $run_as_user,
    notify  => Class['::apache::service'],
  }

  exec { 'install passenger':
    command     => '/var/lib/gems/1.9.1/gems/passenger-4.0.45/bin/passenger-install-apache2-module -a --languages ruby',
    refreshonly => true,
    subscribe   => Package['passenger'],
    notify      => Service['apache2'],
  }
}
