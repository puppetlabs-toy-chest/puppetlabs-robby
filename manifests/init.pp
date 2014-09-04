class robby (
  $deploy_key,
  $deploy_app = true,
  $revision = undef,
  $robby_path  = '/opt/robby',
  $robby_home_directory = undef,
  $run_as_user = 'robby',
  $ldap_admin_cn,
  $ldap_host,
  $ldap_admin_password,
  $ldap_people_ou
) {

  $application_root = "${robby_path}/src"

  if $deploy_app {

    $bundler_require = [
      Class['robby::packages','robby::ruby','::ruby','::ruby::dev'],
      Vcsrepo[$robby_path]
    ]

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
      mode    => '0755',
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

  } else {

    $bundler_require = Class['robby::packages','robby::ruby','::ruby','::ruby::dev']

    $unicorn_require = [
      Class['ruby::dev','robby::ruby','robby::user'],
      File['/var/log/robby','/var/run/robby'],
      Bundler::Install[$application_root]
    ]

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

  file { '/etc/robby_ldap.yaml':
    ensure  => file,
    content => template('robby/ldap.yaml.erb'),
    owner   => 'robby',
    group   => 0,
    mode    => '0640',
    notify  => Unicorn::App['robby'],
  }

  file { '/var/run/robby':
    ensure => directory,
    owner  => 'robby',
    group  => 'robby',
    mode   => '0750',
  }

  file { '/var/log/robby':
    ensure => directory,
    owner  => 'robby',
    group  => 'robby',
    mode   => '0750',
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
