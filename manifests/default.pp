#
# POC common services box:
#
# The POC kit will include a Ubuntu 12.04 box with the following
# services:
#
#   * nfs (datastore)
#   * ntp (time synchronization for ALL boxes in POC environment)
#   * dhcp
#   * tftp
#   * razor (and client)
#
# Copyright 2014, VMware, Inc (greent@vmware.com)

$db_user = 'razor'
$db_password = 'razor'

$server_iface = 'eth1'
$server_ip = '10.127.1.10'

# options for DHCP server.
$dhcp_network = '10.127.1.0'
$dhcp_ntp = $server_ip
$dhcp_dns = '10.127.1.11'
$dhcp_netmask = '255.255.255.0'
$dhcp_range = '10.127.1.100 10.127.1.150'
$dhcp_router = '10.127.1.1'
$server_domain = 'vmware.local'

# ESXi ISO location.
$esx_iso = '/tmp/VMware-VMvisor-Installer-5.5.0-1331820.x86_64.iso'

file { '/etc/network/interfaces':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => 0644,
  content => template('razor/interfaces.erb'),
} ->

file { '/etc/resolvconf/resolv.conf.d/head':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => 0644,
  content => template('razor/head.erb'),
} ->

exec { "/sbin/ifconfig ${server_iface} ${server_ip} netmask ${dhcp_netmask}": } ->

class { 'ntp':
  restrict => [ '127.0.0.1', '-6 ::1', "${dhcp_network} mask ${dhcp_netmask} nomodify notrap nopeer" ],
}

class { 'nfs::server': }

nfs::server::export { '/mnt/datastore':
  ensure   => 'mounted',
  clients => '*(no_subtree_check,no_root_squash,sync,rw)',
  #clients  => "${network_eth1}/${netmask_eth1}(no_subtree_check,no_root_squash,sync,rw)",
  require  => Class['nfs::server'],
}

class { 'dhcpd':
  network => $dhcp_network,
  netmask => $dhcp_netmask,
  ntp     => $dhcp_ntp,
  range   => $dhcp_range,
  router  => $dhcp_router,
  dns     => $dhcp_dns,
  domain  => $server_domain,
}

class { 'tftp':
  directory => '/var/lib/tftpboot',
  address   => $server_ip,
  options  => '--secure',
}

file { '/var/lib/tftpboot/bootstrap.ipxe':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => 0644,
  content => template('razor/bootstrap.ipxe.erb'),
  require => Class['tftp'],
}

file { '/var/lib/tftpboot/undionly.kpxe':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => 0644,
  source  => 'puppet:///modules/razor/undionly.kpxe',
  require => Class['tftp'],
}

class { 'postgresql::server': } ->

# create required role for razor.
postgresql::server::role { $db_user:
  password_hash => postgresql_password($db_user, $db_password),
} ->

# create required razor databases.
postgresql::server::db { [ 'razor_test', 'razor_dev', 'razor_prd' ]:
  user     => $db_user,
  password => postgresql_password($db_user, $db_password),
} ->

# deploy razor using previously created role/databases.
class { 'razor':
  libarchive  => [ 'libarchive12', 'libarchive-dev' ],
  tftp        => false,
  db_user     => $db_user,
  db_password => $db_password,
} ->

# overlay the custom ESXi deployment template on existing razor server install.
file { '/opt/razor/tasks/vmware_esxi/ks.cfg.erb':
  ensure  => file,
  owner   => 'razor-server',
  group   => 'razor-server',
  mode    => 0644,
  source  => 'puppet:///modules/razor/ks.cfg.erb',
  require => Class['razor::server'],
} ->

file { '/opt/razor/tasks/vmware_esxi/joinvcenter.py':
  ensure  => file,
  owner   => 'razor-server',
  group   => 'razor-server',
  mode    => 0644,
  source  => 'puppet:///modules/razor/joinvcenter.py',
} ->

package { 'razor-client':
  ensure   => installed,
  provider => gem,
} ->

exec { 'tar xvf /tmp/microkernel-004.tar -C /var/lib/razor/repo-store/':
  onlyif  => ['test -f /tmp/microkernel-004.tar'],
  creates => '/var/lib/razor/repo-store/microkernel/initrd0.img',
  path    => ['/bin', '/usr/bin'],
} ->

# create broker, policy, and (TODO) the repo.
class { 'razor::instance':
  target_os   => 'esx',
  target_fqdn => $server_domain,
  iso         => $esx_iso,
}
