#!/bin/bash

set -xv

cat <<EOF > /home/ec2-user/master_join_master.yaml
---
- name: Join the second master node to the first master
  hosts: localhost
  become: yes
  vars:
    master_node_ip: "10.0.2.4"
    second_master_ip: "{{ second_master_ip }}"
  tasks:
    - name: Wait until SSH connection to the first master node is available
      wait_for_connection:
        delay: 10
        timeout: 300
      delegate_to: "{{ master_node_ip }}"

    - name: Generate certificate key on the first master node
      shell: kubeadm init phase upload-certs --upload-certs
      delegate_to: "{{ master_node_ip }}"
      register: cert_key
      until: cert_key.rc == 0
      retries: 5
      delay: 10

    - name: Connect to the first master node and get the join command
      shell: kubeadm token create --print-join-command
      delegate_to: "{{ master_node_ip }}"
      register: join_command
      until: join_command.rc == 0
      retries: 5
      delay: 10

    - name: Add --control-plane and --certificate-key to the join command
      set_fact:
        join_command_with_control_plane: "{{ join_command.stdout }} --control-plane --certificate-key {{ cert_key.stdout | regex_replace('.*Your certificate key: (.*)', '\\1') }}"

    - name: Execute the join command on the second master node
      become: yes
      shell: "{{ join_command_with_control_plane }}"
      delegate_to: "{{ second_master_ip }}"
      register: result
      until: result.rc == 0
      retries: 5
      delay: 10
EOF
chown ec2-user:ec2-user /home/ec2-user/master_join_master.yaml

cat <<EOF > /home/ec2-user/node_join_master.yaml
---
- name: Join Kubernetes node to master
  hosts: localhost
  become: yes
  vars:
    master_node_ip: "10.0.2.4"
    node_ip: "{{ node_ip }}"

  tasks:
    - name: Wait until SSH connection to the master node is available
      wait_for_connection:
        delay: 10
        timeout: 300
      delegate_to: "{{ master_node_ip }}"

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
dnf -y install ansible-core.x86_64 git nano puppetserver zsh

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
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

export pupethost=$(hostname | awk '{print $1}')

cat <<EOF > /etc/puppetlabs/puppet/puppet.conf
[main]
certname = $pupethost
server = $pupethost
environment = production
runinterval = 15m
[master]
autosign = true
autosign_config = /etc/puppetlabs/puppet/autosign.conf
EOF

cat <<EOF > /etc/puppetlabs/puppet/autosign.conf
*.10.0.4.*
*.10.0.3.*
*.10.0.2.*
*.10.0.1.*
EOF

mkdir -p /etc/puppetlabs/code/environments/production/manifests/
cat <<EOF > /etc/puppetlabs/code/environments/production/manifests/site.pp
node /^ip-10-0-4-\d{1,3}\.ec2\.internal$/  {
  include nginx
}
EOF

mkdir -p /etc/puppetlabs/code/environments/production/modules/nginx/manifests/
cat <<EOF > /etc/puppetlabs/code/environments/production/modules/nginx/manifests/init.pp
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

cat <<EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking = False
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o IdentityFile=/home/ec2-user/.ssh/id_rsa
EOF

set +xv
cat <<EOF > /home/ec2-user/.ssh/id_rsa

EOF

set -xv

chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
chmod 600 /home/ec2-user/.ssh/id_rsa

systemctl enable --now puppetserver

rpm -i https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.rpm
sudo -u ec2-user sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
usermod -s /usr/bin/zsh ec2-user

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sh ./get_helm.sh
ln -s /usr/local/bin/helm /usr/bin/


systemctl reboot
