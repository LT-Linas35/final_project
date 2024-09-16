#!/bin/bash

set -xv

rpm -Uvh https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
dnf -y install nano puppet-agent nginx

export pupethost=`hostname`

cat <<EOF | tee /etc/puppetlabs/puppet/puppet.conf
[main]
certname = $pupethost
server = ${controller_hostname}
EOF

/opt/puppetlabs/bin/puppet ssl bootstrap

systemctl enable --now puppet
systemctl reboot