#!/bin/bash

sudo rpm -Uvh https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
sudo dnf -y install ansible-core.x86_64 git nano puppetserver
sudo systemctl start --now puppetserver
cat <<EOF > /etc/ansible/hosts
[nginx]
${nginx_ips}

[masters]
${masters_ips}

[nodes]
${nodes1_ips}
${nodes2_ips}
EOF

sudo echo "[ssh_connection]" >> /etc/ansible/ansible.cfg
sudo echo "ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o IdentityFile=/home/ec2-user/.ssh/id_rsa" >> /etc/ansible/ansible.cfg

cat <<EOF > /home/ec2-user/.ssh/id_rsa
${ec2_key}
EOF

sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa
chmod 600 /home/ec2-user/.ssh/id_rsa

ssh-keyscan -t rsa ${nginx_ips} >> /home/ec2-user/.ssh/known_hosts
ssh-keyscan -t rsa ${masters_ips} >> /home/ec2-user/.ssh/known_hosts
ssh-keyscan -t rsa ${nodes1_ips}  >> /home/ec2-user/.ssh/known_hosts
ssh-keyscan -t rsa ${nodes2_ips}  >> /home/ec2-user/.ssh/known_hosts


cat <<EOF > /home/ec2-user/join_master.yaml
---
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
    - name: Run kubeadm join command
      shell: "{{ hostvars[inventory_hostname]['kubeadm_join_command'] }} --ignore-preflight-errors=all"
      register: join_result
      failed_when: join_result.rc != 0
      changed_when: True
EOF

ansible-playbook  /home/ec2-user/join_master.yaml
sudo systemctl reboot