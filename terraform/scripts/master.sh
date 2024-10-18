#!/bin/bash

# Enable verbose mode and command tracing for debugging purposes
set -xv

systemctl stop sshd

dnf -y update
dnf -y upgrade

# Create a systemd service to clean up Kubernetes masters before system shutdown
cat <<EOF > /etc/systemd/system/k8s-masters-cleanup.service
[Unit]
Description=Remove Kubernetes masters from the cluster before shutdown
DefaultDependencies=no
Before=shutdown.target reboot.target halt.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/k8s-master-cleanup.sh
RemainAfterExit=true
TimeoutSec=30

[Install]
WantedBy=halt.target shutdown.target
EOF

# Set executable permissions for the service file
chmod +x /etc/systemd/system/k8s-masters-cleanup.service

# Create a script to remove the Kubernetes master node from the cluster
cat <<EOF > /usr/local/bin/k8s-master-cleanup.sh
#!/bin/bash
export KUBECONFIG=/etc/kubernetes/admin.conf
NODE_NAME=\$(hostname)

# Drain the node, ensuring workloads are evacuated
kubectl drain \$NODE_NAME --ignore-daemonsets --delete-emptydir-data --force

# Remove the node from the cluster
kubectl delete node \$NODE_NAME

# Remove the node from the etcd cluster
ETCDCTL_API=3 etcdctl member remove \$(etcdctl member list | grep \$NODE_NAME | cut -d, -f1)
EOF

# Set executable permissions for the cleanup script
chmod +x /usr/local/bin/k8s-master-cleanup.sh

# systemctl daemon-reload
# systemctl enable --now k8s-master-cleanup.service

# Install necessary packages for kernel and utilities
dnf -y install kernel-devel-$(uname -r)

dnf -y install socat

# Load necessary kernel modules for Kubernetes
modprobe br_netfilter
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe overlay

# Ensure these modules are loaded on boot
cat <<EOF > /etc/modules-load.d/kubernetes.conf
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
overlay
EOF

# Configure sysctl for Kubernetes networking
cat <<EOF > /etc/sysctl.d/kubernetes.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Apply sysctl settings
sysctl --system

# Disable swap, as Kubernetes requires swap to be turned off
swapoff -a
sed -i '/swap/d' /etc/fstab

# Add Docker's official repository and install containerd
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf makecache
dnf -y install containerd.io

# Configure containerd to use systemd as the cgroup driver
sh -c "containerd config default > /etc/containerd/config.toml"
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl enable --now containerd.service

# Set up the Kubernetes repository for version 1.31
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

# Pre-pull Kubernetes images
kubeadm config images pull

# Install Helm (package manager for Kubernetes)
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sed -i 's|/usr/local/bin|/usr/bin|' get_helm.sh
sh ./get_helm.sh
rm ./get_helm.sh

kubeadm init --control-plane-endpoint $(hostname -I) --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=$(hostname -I) --service-cidr=10.96.0.0/12 --upload-certs

# Export the Kubernetes admin config
export KUBECONFIG=/etc/kubernetes/admin.conf

mkdir -p /opt/cni/bin
curl -O -L https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz
tar -C /opt/cni/bin -xzf cni-plugins-linux-amd64-v1.5.1.tgz

chown root -R /opt/cni

# Needs manual creation of namespace to avoid helm error
kubectl create ns kube-flannel
kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged

helm repo add flannel https://flannel-io.github.io/flannel/
helm install flannel --set podCidr="10.244.0.0/16" --namespace kube-flannel flannel/flannel

helm repo add nextcloud https://raw.githubusercontent.com/LT-Linas35/final_project/main/helm-charts/
helm repo update

set +xv # Need to disable debugging because all this will be exposed in to cloud-init-output
helm install nextcloud nextcloud/nextcloud-chart \
--set database.type=${DATABASE_TYPE} \
--set database.name=${DATABASE_NAME} \
--set database.host=${DATABASE_HOST} \
--set database.port=${DATABASE_PORT} \
--set database.user=${DATABASE_USER} \
--set database.password=${DATABASE_PASSWORD} \
--set admin.user=${ADMIN_USER} \
--set admin.password=${ADMIN_PASSWORD} \
--set admin.email=${ADMIN_EMAIL} \
--set redis.host=${REDIS_HOST} \
--set redis.port=${REDIS_PORT} \
--set redis.timeout=${REDIS_TIMEOUT} \
--set redis.dbindex=${REDIS_DBINDEX} \
--set s3.bucket=${S3_BUCKET} \
--set s3.region=${S3_REGION}
set -xv

# Install Argo CD (continuous delivery tool for Kubernetes)
#VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
#curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64
#install -m 555 argocd-linux-amd64 /usr/bin/argocd
#rm argocd-linux-amd64

#kubectl create namespace argocd
#kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=k8s -n kube-system



systemctl reboot
