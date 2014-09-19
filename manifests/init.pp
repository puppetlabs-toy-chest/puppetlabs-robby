class robby (
  $deploy_app = true,
  $version = undef,
  $robby_path  = '/opt/robby',
  $ldap_admin_cn,
  $ldap_host,
  $ldap_admin_password,
  $ldap_people_ou,
) {

  $deploy_version = $version ? {
    undef   => 'latest',
    default => $version
  }

  File {
    owner => 'robby',
    group => 'robby'
  }

  class { 'robby::user': }

  class { 'robby::ruby':
    before => Class['bundler'],
  }

  class { 'robby::packages':
    require => Class['robby::ruby'],
  }

  if $deploy_app {
    package { 'robby':
      ensure   => $deploy_version,
    }
  }

  file { '/etc/robby_ldap.yaml':
    ensure  => file,
    content => template('robby/ldap.yaml.erb'),
    mode    => '0640',
  }

  file { '/var/run/robby':
    ensure => directory,
    mode   => '0755',
  }

  file { '/var/log/robby':
    ensure => directory,
    mode   => '0755',
  }

  bundler::install { $application_root:
    require => Class['robby::packages','robby::ruby','::ruby','::ruby::dev']
  }
}
