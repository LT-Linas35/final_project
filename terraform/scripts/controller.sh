#!/bin/bash

sudo rpm -Uvh https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
sudo dnf -y install ansible-core.x86_64 git nano puppetserver

sudo sed -i 's/JAVA_ARGS="-Xms2g -Xmx2g/JAVA_ARGS="-Xms512m -Xmx512m/' /etc/sysconfig/puppetserver
sudo sed -i '/swap/d' /etc/fstab

export pupethost=`hostname`

sudo cat <<EOF > /etc/puppetlabs/puppet/puppet.conf
[main]
certname = $pupethost
server = $pupethost
environment = production
runinterval = 15m
[master]
autosign = true
autosign_config = /etc/puppetlabs/puppet/autosign.conf
EOF

sudo cat <<EOF > /etc/puppetlabs/puppet/autosign.conf
*.10.0.4.*
*.10.0.3.*
*.10.0.2.*
*.10.0.1.*
EOF

sudo mkdir -p /etc/puppetlabs/code/environments/production/manifests/
sudo cat <<EOF > /etc/puppetlabs/code/environments/production/manifests/site.pp
node /^ip-10-0-4-\d{1,3}\.ec2\.internal$/  {
  include nginx
}
EOF

sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/nginx/manifests/
sudo cat <<EOF > /etc/puppetlabs/code/environments/production/modules/nginx/manifests/init.pp
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

sudo systemctl enable --now puppetserver

#sudo ansible-config init --disabled > /etc/ansible/ansible.cfg

cat <<EOF > /etc/ansible/hosts
[nginx]
${nginx_ips}

[masters]
${k8s_master_ips}

[nodes]
${k8s_nodes_ips}
EOF

sudo cat <<EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking = False
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o IdentityFile=/home/ec2-user/.ssh/id_rsa
EOF


cat <<EOF > /home/ec2-user/.ssh/id_rsa
${ec2_key}
EOF

sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
chmod 600 /home/ec2-user/.ssh/id_rsa


sudo cat <<EOF > /home/ec2-user/join_master.yaml
---
- name: Wait for all nodes to be ready
  hosts: all
  gather_facts: no
  tasks:
    - name: Ensure all hosts are reachable
      wait_for_connection:
        timeout: 3000
        delay: 5
      with_items: "{{ groups['all'] }}"


- name: Generate and distribute kubeadm join command
  hosts: masters
  remote_user: ec2-user
  become: yes
  become_method: sudo
  gather_facts: no

  tasks:
    - name: Generate kubeadm join command
      shell: kubeadm token create --print-join-command --ttl 1h0m0s
      register: kubeadm_join_command
      until: kubeadm_join_command.rc == 0
      retries: 100
      delay: 30
      failed_when: kubeadm_join_command.rc != 0
      changed_when: False

    - name: Distribute kubeadm join command to nodes
      add_host:
        name: "{{ item }}"
        groups: join_nodes
        kubeadm_join_command: "{{ kubeadm_join_command.stdout }}"
      loop: "{{ groups['nodes'] }}"


- name: Join nodes to Kubernetes cluster
  hosts: nodes
  remote_user: ec2-user
  become: yes
  become_method: sudo
  gather_facts: no

  tasks:
    - name: Wait for SSH to be available on node
      wait_for:
        host: "{{ inventory_hostname }}"
        port: 22
        delay: 10
        timeout: 600
        state: started
      retries: 100
      delay: 30
      register: ssh_node_available

    - name: Run kubeadm join command
      shell: "{{ hostvars[inventory_hostname]['kubeadm_join_command'] }} --ignore-preflight-errors=all"
      register: join_result
      until: join_result.rc == 0
      retries: 100
      delay: 30
      failed_when: join_result.rc != 0
      changed_when: True

- name: Get PuppetServer IP (on Ansible controller)
  hosts: localhost
  gather_facts: yes
  tasks:
    - name: Set PuppetServer IP address
      set_fact:
        puppet_server_ip: "{{ ansible_default_ipv4.address }}"
      run_once: true

    - name: Debug PuppetServer IP
      debug:
        msg: "PuppetServer IP is {{ puppet_server_ip }}"

- name: Connect Puppet Agents to PuppetServer
  hosts: all
  become: yes
  gather_facts: yes
  tasks:
    - name: Install Puppet agent
      shell: |
        sudo dnf install -y https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
        sudo dnf install -y puppet-agent
      register: puppet_install
      changed_when: puppet_install.rc == 0

    - name: Add PuppetServer configuration to agent
      copy:
        content: |
          [main]
          certname = {{ ansible_facts['hostname'] }}.ec2.internal
          server = {{ hostvars['localhost']['ansible_facts']['hostname'] }}.ec2.internal
          environment = production
          runinterval = 15m
        dest: /etc/puppetlabs/puppet/puppet.conf

    - name: Enable and start Puppet service
      shell: |
        sudo systemctl enable --now puppet
      register: puppet_service
      changed_when: puppet_service.rc == 0

    - name: Run Puppet agent and connect to PuppetServer
      shell: |
        sudo /opt/puppetlabs/bin/puppet ssl bootstrap
      register: puppet_ssl
      retries: 50
      delay: 30
      until: puppet_ssl.rc == 0
      changed_when: puppet_ssl.rc == 0

    - name: Run the first Puppet agent test
      shell: |
        sudo /opt/puppetlabs/bin/puppet agent --test
      register: puppet_test
      changed_when: puppet_test.rc == 0
EOF

sudo -u ec2-user ansible-playbook  /home/ec2-user/join_master.yaml
sudo systemctl reboot
