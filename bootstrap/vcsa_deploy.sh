#!/bin/bash

set -e

# VMware-ovftool-3.5.0-1274719-lin.x86_64.bundle should already be installed.
# use VMware-ovftool-3.5.0-1274719-lin.x86_64.bundle --extract <dest_dir> for custom (unattended) install.

help()
{
  echo 'this script deploys the VCSA and configures it using puppet'
  echo ''
  echo 'vcsa_deploy.sh <appliance_file>'
  echo ''
  exit 0
}

# run the vcsa configuration manifest
puppet_run()
{
    puppet apply --modulepath=$1/modules $1/modules/vmware-vcsa/manifests/init.pp
}

if [ $# -ne 1 ]; then
  help
elif [ ! -f $PWD/vcsa.conf ]; then
  echo '[ERROR]: unable to find required configuration file vcsa.conf'
  exit 1
fi

OVF_APPLIANCE=$1

source $PWD/vcsa.conf

$OVFTOOL --acceptAllEulas --noSSLVerify --network="${MGMT_NETWORK}" --datastore="${DATASTORE}" --powerOn --vmFolder=${VM_FOLDER} --prop:vami.hostname=${VCSA_HOSTNAME} \
  ${OVF_APPLIANCE} vi://${VCSA_USERNAME}:${VCSA_PASSWORD}@${TARGET_VCENTER}/${TARGET_HOST}

# wait for ssh to come up on the newly provisioned appliance
sleep 60

PUPDIR=`dirname $PWD`
puppet_run $PUPDIR
