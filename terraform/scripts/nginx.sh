#!/bin/bash

set -xv

REPO="prometheus/node_exporter"
LATEST_RELEASE=$(curl --silent "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
VERSION=$${LATEST_RELEASE#v}
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_RELEASE/node_exporter-$VERSION.linux-amd64.tar.gz"
curl -L $DOWNLOAD_URL -o node_exporter-linux-amd64.tar.gz
tar -xvf node_exporter-linux-amd64.tar.gz
cp node_exporter-$VERSION.linux-amd64/node_exporter /usr/local/bin/
chmod +x /usr/local/bin/node_exporter
yes | rm -dR node_exporter-$VERSION.linux-amd64

cat <<EOF | tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

useradd -rs /bin/false node_exporter
systemctl daemon-reload
systemctl enable --now node_exporter


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