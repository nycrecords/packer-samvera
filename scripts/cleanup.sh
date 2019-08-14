#! /bin/bash

# Do some general cleanup
[ -d "/home/centos" ] && cd /home/centos
[ -d "/home/vagrant" ] && cd /home/vagrant
rm -rf install
rm -f nodesource_setup.sh
