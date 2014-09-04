class robby::user (
  $ssh_key,
  $home_directory = '/home/robby'
) {

  user { 'robby':
    ensure => present,
    home   => $home_directory,
  }

  group { 'robby':
    ensure => present,
  }

  file { $home_directory:
    ensure => directory,
    owner  => 'robby',
    group  => 'robby',
    mode   => 0700,
  }

  file { "${home_directory}/.ssh":
    ensure => directory,
    owner  => 'robby',
    group  => 'robby',
    mode   => 0700,
  }

  file { "${home_directory}/.ssh/id_rsa":
    ensure  => file,
    content => template('robby/id_rsa.erb'),
    owner   => 'robby',
    group   => 'robby',
    mode    => 0600,
  }
}
