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

  class { 'robby::packages': }

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

  file { ['/var/log/robby','/var/log/robby/guess_results']:
    ensure => directory,
    mode   => '0755',
  }

  bundler::install { $robby_path:
    require => Class['robby::packages']
  }
}
