#!/bin/bash

set -e

SITE='http://apt.puppetlabs.com/'
REMOTE_FILE='puppetlabs-release-precise.deb'
INSTALL=0
DPKG_ARGS='-i'
RESULT=0

# prerequisite packages
PRE_PKGS='curl git unzip ruby1.9.1 rubygems1.9.1'
GEMS='librarian-puppet net-ssh'

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
  echo '-b: enable bootstrap (puppet run after install)'
  echo ''
}

function prereqs_install()
{
  apt-get update -yq
  apt-get install $* -yq
}

function post_install()
{
  gem install $* --no-rdoc --no-ri
}

function agent_install()
{
  apt-get update -yq
  apt-get install puppet -yq
}

# run some puppet!
function puppet_run()
{
    puppet apply --modulepath=$1/modules $1/manifests/default.pp
}

# if no options a specified the script will perform download AND install
while getopts "bp:ih" OPT
do
  case $OPT in
    h) help; exit 2;;
    i) INSTALL=1;;
    p) PROXY=$OPTARG;;
    b) BOOTSTRAP=1;;
    *) echo 'invalid syntax'; help;;
  esac
done

if [ $INSTALL -eq 1 ]; then
  prereqs_install $PRE_PKGS
  dl $SITE $REMOTE_FILE $PROXY
  install $DPKG_ARGS $REMOTE_FILE
  agent_install
  post_install $GEMS
fi

if [ $BOOTSTRAP ]; then
  PUPDIR=`dirname $PWD`
  puppet_run $PUPDIR
fi
