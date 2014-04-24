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
$server_ip = '10.127.1.10'

# options for DHCP server.
$dhcp_network = '10.127.1.0'
$dhcp_netmask = '255.255.255.0'
$dhcp_ntp = $server_ip
$dhcp_range = '10.127.1.100 10.127.1.150'
$dhcp_router = '10.127.1.1'
$dhcp_dns = '10.127.1.11'
$server_domain = 'vmware.local'

# ESXi ISO location.
$esx_iso = '/tmp/VMware-VMvisor-Installer-5.5.0-1331820.x86_64.iso'
```

## Installation

Install an Ubuntu 12.04 host, the dependencies will later be installed by the 'puppet-install.sh' script.
You will want to give two ethernet interfaces to the Ubuntu Host, one for management of the box itself, and one to bind the dhcp/tftp service on (bootstrap interface). Alternatively you could use one physical interface with VLANs.

Retrieve code and edit parameters (see reference above):

    $ mkdir /etc/puppet
    $ mkdir /etc/puppet/modules
    $ apt-get install git vim-puppet
    $ vim-addons install puppet
    $ cd /etc/puppet/modules/
    $ git clone https://github.com/timops/simplicity.git
    $ vim simplicity/manifests/default.pp
    
Copy the vSphere ESXi ISO and the Razor microkernel into parameter specified directory:    
    
    $ cp VMware-VMvisor-Installer-5.5.0-1331820.x86_64.iso /tmp/VMware-VMvisor-Installer-5.5.0-1331820.x86_64.iso
    $ cp microkernel-004.tar /tmp/microkernel-004.tar
    
Run Puppet:

    $ cd /etc/puppet/modules/simplicity
    $ ./bootstrap/puppet-install.sh -i
    $ librarian-puppet config path --global /etc/puppet/modules/
    $ librarian-puppet install
    $ ./bootstrap/puppet-install.sh -b
    
## Post-install

Reboot VM to ensure that all local DNS configurations (resolvconf) are updated.
razor-client is installed and should be on the user's $PATH.  Run 'razor' to test.


## Support
