class harden {

  # Installing Pam Modules
  package { 'libpam-passwdqc':
    ensure => installed,
  }

  package { 'libpam-tmpdir':
    ensure => installed,
  }

  # On modern Ubuntu, these are symlinks to SSH, so Bastille's protectrhost
  # doesn't work. Just remove the symlinks.
  file { '/usr/bin/rlogin':
    ensure => absent,
  }

  file { '/usr/bin/rsh':
    ensure => absent,
  }

  file { '/usr/bin/rcp':
    ensure => absent,
  }

  # Locking down console logins
  # Deny root login on console(s)
  file { '/etc/securetty':
    ensure  => present,
    content => "null\n",
  }

  file { '/etc/security/access.conf':
    ensure => present,
    source => 'puppet:///modules/harden/etc/security/access.conf',
    owner  => 'root',
    group  => 'root',
  }

  file { '/etc/security/limits.conf':
    ensure => present,
    source => 'puppet:///modules/harden/etc/security/limits.conf',
    owner  => 'root',
    group  => 'root',
  }

  file { '/etc/security/limits.d':
    ensure  => directory,
    purge   => true,
    force   => true,
    recurse => true,
    owner   => 'root',
    group   => 'root',
  }

  # Remove setuid privileges
  file { [
      '/bin/mount',
      '/bin/umount',
      '/bin/fusermount',
      '/usr/bin/arping',
      '/usr/bin/mtr',
      '/usr/bin/traceroute6',
      '/usr/bin/traceroute6.iputils'
    ]:
    mode => '0755',
  }

  # Adjusting kernel networking parameters
  file { '/etc/sysctl.conf':
    ensure => present,
    source => 'puppet:///modules/harden/etc/sysctl.conf',
    notify => Exec['read sysctl.conf'],
    owner  => 'root',
    group  => 'root',
  }

  exec { 'read sysctl.conf':
    command     => '/sbin/sysctl -p',
    refreshonly => true,
  }

  # Set a restrictive umask
  file { '/etc/pam.d/common-session':
    ensure    => present,
    source    => 'puppet:///modules/harden/etc/pam.d/common-session',
    subscribe => Package['libpam-tmpdir'],
    owner     => 'root',
    group     => 'root',
  }

  file { '/etc/pam.d/common-session-noninteractive':
    ensure    => present,
    source    => 'puppet:///modules/harden/etc/pam.d/common-session-noninteractive',
    subscribe => Package['libpam-tmpdir'],
    owner     => 'root',
    group     => 'root',
  }

  file { '/etc/ssh/ssh_config':
    ensure => present,
    source => 'puppet:///modules/harden/etc/ssh/ssh_config',
    owner  => 'root',
    group  => 'root',
  }

  # login(1), init(8) and getty(8) will not perform record-keeping, or
  # attempt to recreate this file, if it doesn't exist.
  file { '/var/log/wtmp':
    ensure => present,
    owner  => 'root',
    group  => 'utmp',
    mode   => '0664',
  }

}
