class robby::ruby {
  class { '::ruby':
    ruby_package => 'ruby1.9.3',
  }

  alternatives { 'ruby':
    path    => '/usr/bin/ruby1.9.1',
    require => Class['::ruby'],
  }

  alternatives { 'gem':
    path    => '/usr/bin/gem1.9.1',
    require => Class['::ruby'],
  }
}
