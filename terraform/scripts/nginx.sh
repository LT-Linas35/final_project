#!/bin/bash

set -xv

cat <<EOF > /home/ec2-user/.ssh/id_rsa
EOF

set -xv

chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
chmod 600 /home/ec2-user/.ssh/id_rsa

rpm -Uvh https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
dnf -y install nano puppet-agent nginx

export pupethost=`hostname`

cat <<EOF > /etc/puppetlabs/puppet/puppet.conf
[main]
certname = $pupethost
server = ${controller_hostname}
EOF

/opt/puppetlabs/bin/puppet ssl bootstrap

systemctl enable puppet
systemctl reboot
