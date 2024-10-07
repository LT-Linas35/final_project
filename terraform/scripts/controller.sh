#!/bin/bash

# Enable verbose mode and command tracing for debugging purposes
set -xv

# Upgrade all system packages to the latest version
dnf -y upgrade

set +xv
cat <<EOF > /home/ec2-user/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----

-----END RSA PRIVATE KEY-----
EOF
chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
chmod 600 /home/ec2-user/.ssh/id_rsa
set -xv 

# Create an Ansible playbook to copy kube config to the ec2-user's home directory
cat <<EOF > /home/ec2-user/get_config.yaml
---
- name: Copy kube config to ec2-user's home directory
  hosts: localhost
  become: yes
  vars:
    remote_ip: "10.0.2.4"
    kube_config_source: "/etc/kubernetes/admin.conf"
    kube_config_temp: "/tmp/admin.conf"
    kube_config_destination: "/home/ec2-user/.kube/config"

  tasks:
    - name: Wait for SSH connection to remote host
      wait_for_connection:
        timeout: 300
      delegate_to: "{{ remote_ip }}"

    - name: Fetch kube config from remote host
      ansible.builtin.fetch:
        src: "{{ kube_config_source }}"
        dest: "{{ kube_config_temp }}"
        flat: yes
      delegate_to: "{{ remote_ip }}"
      become: yes
      become_user: root

    - name: Copy kube config to ec2-user home directory
      ansible.builtin.copy:
        src: "{{ kube_config_temp }}"
        dest: "{{ kube_config_destination }}"
        owner: ec2-user
        group: ec2-user
        mode: '0600'
      become: yes
      become_user: ec2-user
EOF

# Create a systemd service to run the Kubernetes API Flask service
cat <<EOF > /etc/systemd/system/k8s-api.service
[Unit]
Description=K8s API Flask Service
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/python3 /home/ec2-user/k8s-api.py
Restart=always
RestartSec=5
TimeoutStopSec=20

[Install]
WantedBy=multi-user.target
EOF

# Create a Python Flask application to handle Kubernetes API requests
cat <<EOF > /home/ec2-user/k8s-api.py
from flask import Flask, request
import subprocess

app = Flask(__name__)

@app.route('/run-playbook', methods=['POST'])
def run_playbook():
    data = request.get_json(force=True)
    if not data or 'action' not in data:
        return {"status": "error", "message": "Missing action"}, 400

    node_ip = request.remote_addr
    action = data['action']

    if action == "leave_master_node":
        playbook = "/home/ec2-user/node_leave_master.yaml"
        node_hostname = "unknown_hostname"

        try:
            hostname_command = ["getent", "hosts", node_ip]
            hostname_result = subprocess.run(hostname_command, capture_output=True, text=True, check=True)
            node_hostname = hostname_result.stdout.split()[1]
        except (subprocess.CalledProcessError, IndexError):
            print("Failed to resolve hostname from IP address, using default value.")

        command = [
            "ansible-playbook", playbook,
            "-e", f"node_ip={node_ip}",
            "-e", f"node_hostname={node_hostname}"
        ]

    elif action == "join_master_node":
        if 'providerID' not in data:
            return {"status": "error", "message": "Missing providerID for join_master_node action"}, 400
        
        playbook = "/home/ec2-user/node_join_master.yaml"
        providerID = data['providerID']

        command = [
            "ansible-playbook", playbook,
            "-e", f"node_ip={node_ip}",
            "-e", f"providerID={providerID}"
        ]
    else:
        return {"status": "error", "message": "Unknown action"}, 400

    try:
        print(f"Running command: {' '.join(command)}")
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        return {"status": "success", "output": result.stdout}, 200
    except subprocess.CalledProcessError as e:
        return {"status": "error", "output": e.stderr}, 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Set ownership and permissions for the Python Flask application
chown ec2-user:ec2-user /home/ec2-user/k8s-api.py

# Create an Ansible playbook to handle node leave from the Kubernetes master
cat <<EOF > /home/ec2-user/node_leave_master.yaml
---
- name: Leave Kubernetes node from master and remove providerID
  hosts: localhost
  become: yes
  vars:
    master_node_ip: "10.0.2.4"
    node_ip: "{{ node_ip }}"
    node_hostname: "{{ node_hostname }}"

  tasks:
    - name: Wait until SSH connection to the node is available
      wait_for_connection:
        delay: 10
        timeout: 300
      delegate_to: "{{ node_ip }}"

    - name: Drain the Kubernetes node
      shell: >
        KUBECONFIG=/etc/kubernetes/admin.conf kubectl drain {{ node_hostname }}
        --ignore-daemonsets --delete-emptydir-data
      delegate_to: "{{ master_node_ip }}"
      register: drain_result
      until: drain_result.rc == 0
      retries: 5
      delay: 10

    - name: Remove the Kubernetes node from the cluster
      shell: >
        KUBECONFIG=/etc/kubernetes/admin.conf kubectl delete node {{ node_hostname }}
      delegate_to: "{{ master_node_ip }}"
      register: delete_result
      until: delete_result.rc == 0
      retries: 5
      delay: 10

    - name: Debug node removal
      debug:
        msg: "Node {{ node_hostname }} has been successfully removed from the Kubernetes cluster."
    - name: Reset Kubernetes node
      shell: kubeadm reset -f
      become: yes
      delegate_to: "{{ node_ip }}"
      register: reset_result
      until: reset_result.rc == 0
      retries: 5
      delay: 10

    - name: Debug node reset
      debug:
        msg: "Node {{ node_hostname }} has been successfully reset."
EOF

# Set ownership and permissions for the node leave playbook
chown ec2-user:ec2-user /home/ec2-user/node_leave_master.yaml

# Create an Ansible playbook to handle node joining the Kubernetes master
cat <<EOF > /home/ec2-user/node_join_master.yaml
---
- name: Join Kubernetes node to master and patch providerID
  hosts: localhost
  become: yes
  vars:
    master_node_ip: "10.0.2.4"
    node_ip: "{{ node_ip }}"
    provider_id: "{{ providerID }}"

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

    - name: Get the hostname of the node
      shell: hostname
      delegate_to: "{{ node_ip }}"
      register: node_hostname

    - name: Patch the Kubernetes node with providerID
      shell: >
        KUBECONFIG=/etc/kubernetes/admin.conf kubectl patch node {{ node_hostname.stdout }}
        -p '{"spec": {"providerID": "{{ provider_id }}"}}'
      delegate_to: "{{ master_node_ip }}"
      register: patch_result
      until: patch_result.rc == 0
      retries: 5
      delay: 10

    - name: Debug provider_id
      debug:
        msg: "Provider ID: {{ provider_id }}"
EOF

# Set ownership and permissions for the node join playbook
chown ec2-user:ec2-user /home/ec2-user/node_join_master.yaml

# Upgrade all system packages again
dnf -y upgrade

# Install Puppet, Ansible, Git, Nano, Puppetserver, Zsh, and Pip
#dnf install -y https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
dnf -y install ansible-core.x86_64 git nano zsh pip #puppetserver 

# Install Flask for Python
sudo -u ec2-user pip install flask

# Create Kubernetes repository configuration
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Install Kubernetes components
dnf makecache; dnf install -y kubelet kubectl --disableexcludes=kubernetes

# Adjust Puppetserver Java memory settings for a lower memory footprint
#sed -i 's/JAVA_ARGS="-Xms2g -Xmx2g/JAVA_ARGS="-Xms512m -Xmx512m/' /etc/sysconfig/puppetserver

# Disable swap as Kubernetes requires it to be turned off
sed -i '/swap/d' /etc/fstab

# Set Puppet hostname
#export pupethost=$(hostname | awk '{print $1}')

# Configure Puppet with autosign for specific subnets
#cat <<EOF > /etc/puppetlabs/puppet/puppet.conf
#[main]
#certname = $pupethost
#server = $pupethost
#environment = production
#runinterval = 15m
#[master]
#autosign = true
#autosign_config = /etc/puppetlabs/puppet/autosign.conf
#EOF

# Create autosign configuration
#cat <<EOF > /etc/puppetlabs/puppet/autosign.conf
#*.10.0.4.*
#*.10.0.3.*
#*.10.0.2.*
#*.10.0.1.*
#EOF

# Create Puppet manifests for managing Nginx
#mkdir -p /etc/puppetlabs/code/environments/production/manifests/
#cat <<EOF > /etc/puppetlabs/code/environments/production/manifests/site.pp
#node /^ip-10-0-4-\d{1,3}\.ec2\.internal$/  {
#  include nginx
#}
#EOF

#mkdir -p /etc/puppetlabs/code/environments/production/modules/nginx/manifests/
#cat <<EOF > /etc/puppetlabs/code/environments/production/modules/nginx/manifests/init.pp
#class nginx {
#  package { 'nginx':
#    ensure => installed,
#  }

#  service { 'nginx':
#    ensure    => running,
#    enable    => true,
#    subscribe => Package['nginx'],
#  }
#}
#EOF

# Configure Ansible to disable host key checking and set SSH connection settings
cat <<EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking = False
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o IdentityFile=/home/ec2-user/.ssh/id_rsa
EOF

# Enable and start the Puppet server service
#systemctl enable --now puppetserver

# Install Helm, a Kubernetes package manager
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sh ./get_helm.sh
ln -s /usr/local/bin/helm /usr/bin/

# Enable the Kubernetes API Flask service
systemctl enable k8s-api.service

# Install k9s, a CLI tool for managing Kubernetes clusters
rpm -i https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.rpm

# Install Oh My Zsh for better terminal experience and change shell to zsh for ec2-user
sudo -u ec2-user sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
usermod -s /usr/bin/zsh ec2-user

# Update .zshrc to check for kube config and run an Ansible playbook if it doesn't exist
cat <<EOF >> /home/ec2-user/.zshrc

KUBE_CONFIG="\$HOME/.kube/config"

if [ ! -f "\$KUBE_CONFIG" ]; then
    echo "Kube config file not found. Running Ansible playbook to copy it."
    mkdir -p \$HOME/.kube
    ansible-playbook /home/ec2-user/get_config.yaml
fi
EOF

# Reboot the system to apply changes
systemctl reboot
