#!/bin/bash

set -xv

mkdir -p /etc/prometheus
REPO="prometheus/prometheus"
LATEST_RELEASE=$(curl --silent "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
VERSION=$${LATEST_RELEASE#v}
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_RELEASE/prometheus-$VERSION.linux-amd64.tar.gz"
curl -L $DOWNLOAD_URL -o prometheus-linux-amd64.tar.gz
tar -xvf prometheus-linux-amd64.tar.gz
cp prometheus-$VERSION.linux-amd64/prometheus /usr/local/bin/
cp prometheus-$VERSION.linux-amd64/promtool /usr/local/bin/
cp -R prometheus-$VERSION.linux-amd64/console_libraries /etc/prometheus/
cp -R prometheus-$VERSION.linux-amd64/consoles /etc/prometheus/
chmod +x /usr/local/bin/prometheus
chmod +x /usr/local/bin/promtool
yes | rm -dR prometheus-$VERSION.linux-amd64/

cat <<EOF | tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'ec2_instances'
    ec2_sd_configs:
      - region: us-east-1
    relabel_configs:
      - source_labels: [__meta_ec2_private_ip]
        target_label: __address__
        replacement: '$${1}:9100'
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

cat <<EOF | tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

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
systemctl enable --now prometheus
systemctl enable --now node_exporter


cat <<EOF | tee /home/ec2-user/master_join_master.yaml
---
- name: Join second master node to first master
  hosts: localhost
  become: yes
  vars:
    master_node_ip: "10.0.2.4"
    second_master_ip: "{{ second_master_ip }}"
  tasks:
    - name: Generate certificate key on first master node
      shell: kubeadm init phase upload-certs --upload-certs
      delegate_to: "{{ master_node_ip }}"
      register: cert_key
      until: cert_key.rc == 0
      retries: 50
      delay: 10

    - name: Connect to first master node and get join command
      shell: kubeadm token create --print-join-command
      delegate_to: "{{ master_node_ip }}"
      register: join_command
      until: join_command.rc == 0
      retries: 50
      delay: 10

    - name: Add --control-plane and --certificate-key to the join command
      set_fact:
        join_command_with_control_plane: "{{ join_command.stdout }} --control-plane --certificate-key {{ cert_key.stdout | regex_replace('.*Your certificate key: (.*)', '\\1') }}"

    - name: Run join command on the second master node
      become: yes
      shell: "{{ join_command_with_control_plane }}"
      delegate_to: "{{ second_master_ip }}"
      register: result
      until: result.rc == 0
      retries: 50
      delay: 10
EOF
chown ec2-user:ec2-user /home/ec2-user/master_join_master.yaml

cat <<EOF | tee /home/ec2-user/node_join_master.yaml
---
- name: Join Kubernetes node to master
  hosts: localhost
  become: yes
  vars:
    master_node_ip: "10.0.2.4"
    node_ip: "{{ node_ip }}"

  tasks:
    - name: Get join command from master node
      shell: kubeadm token create --print-join-command
      delegate_to: "{{ master_node_ip }}"
      register: join_command
      until: join_command.rc == 0
      retries: 5
      delay: 10  # seconds between retries

    - name: Run kubeadm join command on the node
      become: yes
      shell: "{{ join_command.stdout }}"
      delegate_to: "{{ node_ip }}"
      register: result
      until: result.rc == 0
      retries: 5
      delay: 10
EOF
chown ec2-user:ec2-user /home/ec2-user/node_join_master.yaml

rpm -Uvh https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
dnf -y install ansible-core.x86_64 git nano puppetserver

cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

dnf makecache; dnf install -y kubelet kubectl --disableexcludes=kubernetes


sed -i 's/JAVA_ARGS="-Xms2g -Xmx2g/JAVA_ARGS="-Xms512m -Xmx512m/' /etc/sysconfig/puppetserver
sed -i '/swap/d' /etc/fstab

export pupethost=`hostname`

cat <<EOF | tee /etc/puppetlabs/puppet/puppet.conf
[main]
certname = $pupethost
server = $pupethost
environment = production
runinterval = 15m
[master]
autosign = true
autosign_config = /etc/puppetlabs/puppet/autosign.conf
EOF

cat <<EOF | tee /etc/puppetlabs/puppet/autosign.conf
*.10.0.4.*
*.10.0.3.*
*.10.0.2.*
*.10.0.1.*
EOF

mkdir -p /etc/puppetlabs/code/environments/production/manifests/
cat <<EOF | tee /etc/puppetlabs/code/environments/production/manifests/site.pp
node /^ip-10-0-4-\d{1,3}\.ec2\.internal$/  {
  include nginx
}
EOF

mkdir -p /etc/puppetlabs/code/environments/production/modules/nginx/manifests/
cat <<EOF | tee /etc/puppetlabs/code/environments/production/modules/nginx/manifests/init.pp
class nginx {
  package { 'nginx':
    ensure => installed,
  }

  service { 'nginx':
    ensure    => running,
    enable    => true,
    subscribe => Package['nginx'],
  }
}
EOF

cat <<EOF | tee /etc/ansible/ansible.cfg
[defaults]
host_key_checking = False
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o IdentityFile=/home/ec2-user/.ssh/id_rsa
EOF

set +xv
cat <<EOF > /home/ec2-user/.ssh/id_rsa
${ec2_key}
EOF

set -xv

chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
chmod 600 /home/ec2-user/.ssh/id_rsa

systemctl enable --now puppetserver


systemctl reboot
