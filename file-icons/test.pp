class nginx (
  String $version        = 'installed',
  Boolean $manage_repo   = true,
  Integer $worker_procs  = $facts['processors']['count'],
) {
  if $manage_repo {
    apt::source { 'nginx':
      location => 'http://nginx.org/packages/ubuntu',
      repos    => 'nginx',
      key      => { 'id' => '573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62' },
    }
  }

  package { 'nginx':
    ensure  => $version,
    require => Apt::Source['nginx'],
  }

  file { '/etc/nginx/nginx.conf':
    ensure  => file,
    content => template('nginx/nginx.conf.erb'),
    notify  => Service['nginx'],
  }

  service { 'nginx':
    ensure => running,
    enable => true,
  }
}
