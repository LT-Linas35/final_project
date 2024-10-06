#!/bin/bash

# Enable verbose mode and command tracing for debugging purposes
set -xv

# Create systemd service for sending EC2 metadata to controller
cat <<EOF > /etc/systemd/system/ec2_post.service
[Unit]
Description=Send EC2 Metadata to Controller
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=bash /home/ec2-user/send_metadata.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

# Script to send EC2 instance metadata to the controller
cat <<EOF > /home/ec2-user/send_metadata.sh
#!/bin/bash
availability_zone=\$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
instance_id=\$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
provider_id="aws:///\$availability_zone/\$instance_id"
# Send metadata to controller until successful
until curl -X POST http://${controller_hostname}:5000/run-playbook -H "Content-Type: application/json" -d "{\"providerID\": \"\$provider_id\", \"action\": \"join_master_node\"}"; do
  echo "Waiting for server connection..."; sleep 5;
done
EOF

# Set executable permissions for the send_metadata.sh script
chmod +x /home/ec2-user/send_metadata.sh

# Script to send metadata for leaving the Kubernetes master node
cat <<EOF > /home/ec2-user/send_metadata_to_leave.sh
#!/bin/bash
# Send request to controller to leave master node
until curl -X POST http://${controller_hostname}:5000/run-playbook -H "Content-Type: application/json" -d '{"action": "leave_master_node"}'; do
  echo "Waiting for server connection..."
  sleep 5
done

# Remove CNI configurations
sudo rm -rf /etc/cni/net.d/*
EOF

# Set executable permissions for the send_metadata_to_leave.sh script
chmod +x /home/ec2-user/send_metadata_to_leave.sh

# Create systemd service for sending leave node metadata
cat <<EOF > /etc/systemd/system/send_leave_node.service
[Unit]
Description=Send EC2 Metadata Leave Node Service
After=shutdown.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user
ExecStart=bash send_metadata_to_leave.sh
Restart=no
TimeoutStopSec=20

[Install]
WantedBy=multi-user.target
EOF

# Enable the EC2 post service and send leave node service
systemctl enable ec2_post.service
systemctl enable send_leave_node.service

# Install Puppet and additional utilities
rpm -Uvh https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
dnf -y upgrade
dnf -y install nano kernel-devel-$(uname -r) puppet-agent socat

# Load necessary kernel modules for Kubernetes networking
modprobe br_netfilter
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe overlay

# Ensure these kernel modules are loaded on boot
cat <<EOF > /etc/modules-load.d/kubernetes.conf
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
overlay
EOF

# Configure sysctl settings for Kubernetes networking
cat <<EOF > /etc/sysctl.d/kubernetes.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Apply sysctl settings
sysctl --system

# Disable swap as Kubernetes requires swap to be turned off
swapoff -a
sed -i '/swap/d' /etc/fstab

# Add Docker's official repository and install containerd
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf makecache
dnf -y install containerd.io

# Configure containerd to use systemd as the cgroup driver
sh -c "containerd config default > /etc/containerd/config.toml" ; cat /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl enable --now containerd.service

# Set up Kubernetes repository
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
dnf makecache; dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet.service

# Configure Puppet agent
export pupethost=$(hostname | awk '{print $1}')
cat <<EOF > /etc/puppetlabs/puppet/puppet.conf
[main]
certname = $pupethost
server = ${controller_hostname}
EOF

# Bootstrap Puppet SSL certificates and enable Puppet service
/opt/puppetlabs/bin/puppet ssl bootstrap
systemctl enable puppet

# Reboot the system to apply changes
systemctl reboot