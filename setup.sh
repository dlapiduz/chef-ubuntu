#!/bin/bash
set -e -x
export DEBIAN_FRONTEND=noninteractive

# update the apt library with the current versions
apt-get --yes --quiet update

apt-get --yes --quiet install build-essential zlib1g zlib1g-dev libreadline6 libreadline6-dev libssl-dev libyaml-dev git libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison

cd /tmp && wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz

tar xzvf ruby-1.9.3-p194.tar.gz

cd /tmp/ruby-1.9.3-p194
./configure --prefix=/usr/local --enable-shared --disable-install-doc --with-opt-dir=/usr/local/lib
make && make install

gem install chef ohai ruby-shadow --no-ri --no-rdoc

cd /etc/ && git clone http://github.com/dlapiduz/chef-ubuntu chef

chef-solo -c /etc/chef/solo.rb -j /etc/chef/dna.json

# create a 'done' file so other scripts can know we're all finished.
touch ~/complete