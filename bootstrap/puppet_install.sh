#!/bin/bash

set -e

SITE='http://apt.puppetlabs.com/'
REMOTE_FILE='puppetlabs-release-precise.deb'
INSTALL=1
DPKG_ARGS='-i'
RESULT=0

# prerequisite packages
OTHER_PKGS='curl git unzip rubygems'

# retrieve repo dpkg from puppetlabs
function dl()
{
  if [ -z $3 ]; then
    curl -O $1$2
  else
    curl -O $1$2 -x $3
  fi
}

# install repo configurator
function install()
{
  dpkg $1 $2
}

function help()
{
  echo 'shell script to deploy and execute initial puppet run'
  echo 'currently only supports ubuntu 12.04'
  echo ''
  echo 'puppet_install.sh [-dhp]'
  echo ''
  echo '-i: install puppet'
  echo '-h: help'
  echo '-p: url of proxy server (for curl)'
  echo '-b: name of the puppet zipfile to bootstrap from'
  echo ''
}

function prereqs_install()
{
  apt-get update -yq
  apt-get install $1 -yq
}

function agent_install()
{
  apt-get update -yq
  apt-get install unzip git puppet -yq
}

# extract modules and depedent manifests in current directory, then invoke the run
function puppet_run()
{
    unzip -qq $1 -d $PWD
    puppet apply  --modulepath=$PWD/$PUPDIR/modules $PWD/$PUPDIR/manifests/default.pp
}

# if no options a specified the script will perform download AND install
while getopts "b:p:ih" OPT
do
  case $OPT in
    h) help; exit 2;;
    i) INSTALL=1;;
    p) PROXY=$OPTARG;;
    b) BOOTSTRAP=$OPTARG;;
    *) echo 'invalid syntax'; help;;
  esac
done

if [ $INSTALL ]; then
  prereqs_install $OTHER_PKGS
  dl $SITE $REMOTE_FILE $PROXY
  install $DPKG_ARGS $REMOTE_FILE
  agent_install
fi

if [ $BOOTSTRAP ]; then
  PUPDIR=${BOOTSTRAP/%.[a-z]*}
  puppet_run $BOOTSTRAP $PUPDIR
fi
