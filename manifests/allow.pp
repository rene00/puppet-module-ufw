define ufw::allow($proto='tcp', $port='all', $ip='', $from='any', $direction='in', $log='') {

  if $::ipaddress_eth0 != undef {
    $ipadr = $ip ? {
      ''      => $::ipaddress_eth0,
      default => $ip,
    }
  } else {
    $ipadr = 'any'
  }

  $from_match = $from ? {
    'any'   => 'Anywhere',
    default => "$from/$proto",
  }

  if $log != '' {
	$log_rule = $log ? {
		'log-all' => 'log-all',
		default   => 'log',
	}
  } else {
	$log_rule = ''
  }

  exec { "ufw-allow-${direction}-${proto}-from-${from}-to-${ipadr}-port-${port}":
    command => $port ? {
      'all'   => "ufw allow $direction $log_rule proto $proto from $from to $ipadr",
      default => "ufw allow $direction $log_rule proto $proto from $from to $ipadr port $port",
    },
    unless  => $port ? {
      'all'   => "ufw status | grep -E \"$ipadr/$proto +ALLOW +$from_match\"",
      default => "ufw status | grep -E \"$ipadr $port/$proto +ALLOW +$from_match\"",
    },
    require => Exec['ufw-default-deny-in', 'ufw-default-deny-out'],
    before  => Exec['ufw-enable'],
  }
}
