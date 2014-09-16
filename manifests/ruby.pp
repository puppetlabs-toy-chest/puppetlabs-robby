class robby::ruby {
  include ::ruby

  alternatives { 'ruby':
    path    => '/usr/bin/ruby1.9.1',
    require => Class['::ruby'],
  }

  alternatives { 'gem':
    path    => '/usr/bin/gem1.9.1',
    require => Class['::ruby'],
  }
}
