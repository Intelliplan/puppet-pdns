# = Class: pdns::nameserver
#
# Installs and configures a PowerDNS nameserver - www.powerdns.com
#
# Currently supported backends: sqlite, postgresql
#
# Currently only supported on RedHat-based systems
#
# For more information see https://github.com/erwbgy/puppet-pdns/
class pdns::nameserver(
  $listen_address = $::ipaddress,
  $backend        = 'sqlite',
  $forward_domain = undef,
  $reverse_domain = undef,
  $use_hiera      = true,
  $gpsql_user     = 'pdns',
  $gpsql_dbname   = 'powerdns',
  $gpsql_host     = '127.0.0.88',
  $gpsql_password = 'password',


) {
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    default: {
      fail('This module currently only supports RedHat-based systems')
    }
  }
  if $use_hiera {
    $pdns = hiera_hash('pdns', undef)
    if $pdns {
      $nameserver = $pdns['nameserver']
      notify { $nameserver: }
      if $nameserver {
        class { 'pdns::nameserver::config':
          backend => $nameserver['backend'] ? {
            undef   => $backend,
            default => $nameserver['backend'],
          },
          listen_address => $nameserver['listen_address'] ? {
            undef   => $listen_address,
            default => $nameserver['listen_address'],
          },
          forward_domain => $nameserver['forward_domain'] ? {
            undef   => $forward_domain,
            default => $nameserver['forward_domain'],
          },
          reverse_domain => $nameserver['reverse_domain'] ? {
            undef   => $reverse_domain,
            default => $nameserver['reverse_domain'],
          },
          gpsql_host => $nameserver['gpsql_host'] ? {
            undef   => $gpsql_host,
            default => $nameserver['gpsql_host'],
          },
          gpsql_password => $nameserver['gpsql_password'] ? {
            undef   => $gpsql_password,
            default => $nameserver['gpsql_password'],
          },
          gpsql_user => $nameserver['gpsql_user'] ? {
            undef   => $gpsql_user,
            default => $nameserver['gpsql_user'],
          },
          gpsql_dbname => $nameserver['gpsql_dbname'] ? {
            undef   => $gpsql_dbname,
            default => $nameserver['gpsql_dbname'],
          },
        }
        class { 'pdns::nameserver::install':
          backend        => $nameserver['backend'] ? {
            undef   => $backend,
            default => $nameserver['backend'],
          },
        }
        include pdns::nameserver::service
      }
    }
  }
  else {
    class { 'pdns::nameserver::config':
      backend        => $backend,
      listen_address => $listen_address,
      forward_domain => $forward_domain,
      reverse_domain => $reverse_domain,
      gpsql_user     => $gpsql_user,
      gpsql_dbname   => $gpsql_dbname,
      gpsql_host     => $gpsql_host,
      gpsql_password => $gpsql_password,
    }
    class { 'pdns::nameserver::install':
      backend        => $backend,
    }
    include pdns::nameserver::service
  }
}
