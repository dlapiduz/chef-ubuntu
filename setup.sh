#!/bin/bash
set -e -x
export DEBIAN_FRONTEND=noninteractive

# update the apt library with the current versions
apt-get --yes --quiet update

apt-get --yes --quiet install build-essential zlib1g zlib1g-dev libreadline5 libreadline-gplv2-dev libssl-dev git

curl -L get.rvm.io | bash -s stable

source /etc/profile.d/rvm.sh

rvm install 1.9.3-p125 --default

gem install chef ohai ruby-shadow --no-ri --no-rdoc

cd /etc/ && git clone http://github.com/dlapiduz/chef-ubuntu chef

chef-solo -c /etc/chef/solo.rb -j /etc/chef/dna.json

# create a 'done' file so other scripts can know we're all finished.
touch ~/complete