#!/bin/bash

# Enable verbose mode and command tracing for debugging purposes
set -xv

# Upgrade all system packages
dnf -y upgrade

# Upgrade system packages again for any additional updates
dnf -y upgrade 

# Set proper permissions for the SSH private key to ensure security
chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
chmod 600 /home/ec2-user/.ssh/id_rsa

# Install Puppet, Nginx, and Nano text editor
#rpm -Uvh https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
dnf -y install nano nginx #puppet-agent

# Set Puppet server hostname
#export pupethost=$(hostname)

# Configure Puppet agent settings
#cat <<EOF > /etc/puppetlabs/puppet/puppet.conf
#[main]
#certname = $pupethost
#server = ${controller_hostname}
#EOF

# Bootstrap Puppet SSL certificates to establish trust with the Puppet server
#/opt/puppetlabs/bin/puppet ssl bootstrap

# Enable Puppet service to run on system startup
#systemctl enable puppet

# Reboot the system to apply all changes
systemctl reboot