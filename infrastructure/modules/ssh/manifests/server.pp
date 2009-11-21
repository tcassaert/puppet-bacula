class ssh::server  inherits ssh {
  include ssh
  package{'openssh-server':
    ensure  => latest, 
    require => Package['openssh'],
    notify  => Service['sshd'],
  }  
  file{'sshd_config':
    source => '/etc/ssh/sshd_config',
    notify => Service['sshd'],
    require => Package['openssh-server'],
    mode   => 640,
  }
  service{"sshd":
    ensure     => running,
    enabled    => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
