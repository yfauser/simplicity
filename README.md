# Simplicity

This project aims to deploy a Razor environment setup to quickly pump out fully configured ESXi infrastructure.

## Dependencies

* Tested operating system(s): Ubuntu 12.04 x86_64
* Ruby 1.9.x
* Puppet 3.4.x or higher
* net-ssh gem (required for vmware-vcsa Puppet module)
* librarian-puppet gem

## Pre-install

* Download ESXi 5.5 media from [http://www.vmware.com/](http://www.vmware.com/)
* Download the Razor microkernel from [http://links.puppetlabs.com/razor-microkernel-latest.tar](http://links.puppetlabs.com/razor-microkernel-latest.tar)

## Parameters

```Puppet
# default.pp
#
# 

# Interface to be used for tftp/dhcpd/etc.
$server_iface = 'eth1'
$server_ip = $::ipaddress_eth1

# options for DHCP server.
$dhcp_network = $::network_eth1
$dhcp_netmask = $::network_eth1
$dhcp_ntp = $::network_eth1
$dhcp_range = '10.127.1.100 10.127.1.150'
$dhcp_router = '10.127.1.1'
$dhcp_dns = '10.127.1.11'
$server_domain = 'vmware.local'

# ESXi ISO location.
$esx_iso = '/tmp/VMware-VMvisor-Installer-5.5.0-1331820.x86_64.iso'
```

## Installation

Retrieve code and edit parameters (see reference above):

    $ git clone git@github.com:timops/simplicity.git
    $ vi simplicity/manifests/default.pp
    
Copy ISO into parameter specified directory:    
    
    $ cp VMware-VMvisor-Installer-5.5.0-1331820.x86_64.iso /tmp/VMware-VMvisor-Installer-5.5.0-1331820.x86_64.iso
    
Run Puppet:

    $ cd simplicity
    $ librarian-puppet install
    $ puppet apply --moduledir=./modules ./manifests/default.pp
    
Copy Microkernel into required path:

    $ tar xvf microkernel-004.tar -C /var/lib/razor/repo-store/

## Post-install

razor-client is installed and should be on the user's $PATH.  Run 'razor' to test.


## Support
