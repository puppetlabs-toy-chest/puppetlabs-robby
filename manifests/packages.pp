class robby::packages { 

  #$gems = [
  #  'shotgun',
  #  'sinatra',
  #  'sinatra-croon',
  #  'parslet',
  #  'activeldap',
  #  'sinatra-contrib',
  #  'sinatra-websocket',
  #  'data_mapper',
  #  'rack-mobile-detect',
  #  'dm-postgres-adapter',
  #  'json',
  #  'rack',
  #  'rmagick',
  #  'fileutils',
  #  'thin',
  #  'unicorn',
  #  'kgio',
  #  'minitest',
  #  'atomic',
  #  'thread_safe',
  #  'tzinfo',
  #  'multi_json',
  #  'addressable',
  #  'rack-protection',
  #  'activesupport',
  #  'activemodel',
  #  'gettext',
  #  'gettext_i18n_rails',
  #  'builder',
  #  'ruby-ldap'
  #]

  $dev_packages = [
    'libpq-dev',
    'libldap2-dev',
    'libsasl2-dev',
    'libcurl4-openssl-dev',
    'libmagick++-dev'
  ]

  package { $dev_packages:
    ensure => installed,
  }

  #package { 'passenger':
  #  ensure   => $passenger_version,
  #  provider => gem,
  #  notify   => Service['apache2'],
  #}

  #package { $gems:
  #  ensure   => installed,
  #  provider => gem,
  #  require  => [Alternatives['gem','ruby'],Package[$dev_packages]],
  #  notify   => Service['apache2'],
  #}
}
