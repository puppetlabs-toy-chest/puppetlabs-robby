class robby::user (
  $home_directory = '/home/robby'
) {

  user { 'robby':
    ensure => present,
    home   => $home_directory,
    system => true,
  }

  group { 'robby':
    ensure => present,
  }
}
