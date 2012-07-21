class ufw {
  package { 'ufw':
    ensure => present,
  }

  Package['ufw'] -> Exec['ufw-default-deny-in'] -> Exec['ufw-default-deny-out'] -> Exec['ufw-enable']

  exec { 'ufw-default-deny-in':
    command => 'ufw default deny incoming',
    unless  => 'ufw status verbose | grep \"[D]efault: deny (incoming)',
  }

  exec { 'ufw-default-deny-out':
    command => 'ufw default deny outgoing',
    unless  => 'ufw status verbose | grep \"deny (outgoing)\"',
  }

  exec { 'ufw-enable':
    command => 'yes | ufw enable',
    unless  => 'ufw status | grep \"[S]tatus: active\"',
  }

  service { 'ufw':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    subscribe => Package['ufw'],
  }
}
