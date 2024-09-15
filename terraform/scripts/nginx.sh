#!/bin/bash
sudo systemctl stop sshd

sudo rpm -Uvh https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
sudo dnf -y install nano puppet-agent

export pupethost=`hostname`

sudo cat <<EOF > /etc/puppetlabs/puppet/puppet.conf
[main]
certname = $pupethost
server = ${controller_hostname}
EOF


sudo systemctl enable --now puppet
