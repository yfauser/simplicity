# Simplicity

This project aims to deploy a Razor environment setup to quickly pump out fully configured ESXi infrastructure.

## Dependencies

* Tested operating system(s): Ubuntu 12.04 x86_64
* git
* Ruby 1.9.x
* Ruby-dev 1.9.x
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

Install an Ubuntu 12.04 host with the dependencies described above:

See this link on how to install the latest Puppet release on Ubuntu: http://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html

    $ apt-get install ruby1.9.1 ruby1.9.1-dev git puppet build-essential vim-puppet
    $ gem install net-ssh
    $ gem install librarian-puppet
    $ vim-addon install puppet

Retrieve code and edit parameters (see reference above):

    $ cd /etc/puppet/modules/
    $ git clone https://github.com/timops/simplicity.git
    $ vim simplicity/manifests/default.pp
    
Copy the vSphere ESXi ISO and the Razor microkernel into parameter specified directory:    
    
    $ cp VMware-VMvisor-Installer-5.5.0-1331820.x86_64.iso /tmp/VMware-VMvisor-Installer-5.5.0-1331820.x86_64.iso
    $ cp microkernel-004.tar /tmp/microkernel-004.tar
    
Run Puppet:

    $ cd simplicity
    $ ./bootstrap/puppet-install.sh -i
    $ librarian-puppet install
    $ ./bootstrap/puppet-install.sh -b
    
## Post-install

Reboot VM to ensure that all local DNS configurations (resolvconf) are updated.
razor-client is installed and should be on the user's $PATH.  Run 'razor' to test.


## Support
