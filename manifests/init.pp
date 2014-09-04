class robby (
  $deploy_key,
  $revision = undef,
  $robby_path  = '/opt/robby',
  $robby_home_directory = undef,
  $run_as_user = 'robby',
  $environment = 'production',
) {

  $application_root = "${robby_path}/src"

  if $environment == 'development' {
    $bundler_require = Class['robby::packages','robby::ruby']
    $unicorn_require = [
      Class['ruby::dev','robby::ruby','robby::user'],
      File['/var/log/robby','/var/run/robby'],
      Bundler::Install[$application_root]
    ]

  } else {
    $bundler_require = [Class['robby::packages','robby::ruby'], Vcsrepo[$robby_path]]
    $unicorn_require = [
      Class['ruby::dev','robby::ruby','robby::user'],
      File['/var/log/robby','/var/run/robby'],
      Bundler::Install[$application_root],
      Vcsrepo[$robby_path]
    ]

    file { $robby_path:
      ensure  => directory,
      owner   => 'robby',
      group   => 'robby',
      mode    => 0755,
      require => Class['robby::user'],
    }

    vcsrepo { $robby_path:
      ensure   => present,
      provider => git,
      source   => 'git@github.com:puppetlabs/OfficeMap',
      revision => $revision,
      user     => 'robby',
      require  => [File[$robby_path],Class['robby::user']],
    }
  }

  class { 'robby::user':
    ssh_key        => $deploy_key,
    home_directory => $robby_home_directory,
  }

  class { 'robby::ruby': }

  class { 'robby::packages':
    require => Class['robby::ruby'],
  }

  bundler::install { $application_root:
    require => $bundler_require,
  }

  file { '/var/run/robby':
    ensure => directory,
    owner  => 'robby',
    group  => 'robby',
    mode   => 0750,
  }

  file { '/var/log/robby':
    ensure => directory,
    owner  => 'robby',
    group  => 'robby',
    mode   => 0750,
  }

  unicorn::app { 'robby':
    approot     => $application_root,
    config_file => '/etc/unicorn_robby.rb',
    logdir      => '/var/log/robby',
    pidfile     => "/var/run/robby/unicorn.pid",
    socket      => "/var/run/robby/unicorn.sock",
    user        => $run_as_user,
    group       => $run_as_user,
    preload_app => true,
    rack_env    => 'production',
    source      => 'bundler',
    require     => $unicorn_require,
  }
}
