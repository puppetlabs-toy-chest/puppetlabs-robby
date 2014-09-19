class robby::packages { 

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
}
