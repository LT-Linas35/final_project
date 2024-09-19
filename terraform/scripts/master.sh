#!/bin/bash

set -xv 

systemctl stop sshd

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


cat <<EOF | tee /etc/systemd/system/k8s-master-cleanup.service
[Unit]
Description=Remove Kubernetes master node from cluster before shutdown
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

chmod +x /usr/local/bin/k8s-master-cleanup.sh

systemctl daemon-reload
systemctl enable k8s-master-cleanup.service


cat <<EOF | tee /usr/local/bin/k8s-master-cleanup.sh
#!/bin/bash
export KUBECONFIG=/etc/kubernetes/admin.conf
NODE_NAME=$(hostname)
kubectl drain $NODE_NAME --ignore-daemonsets --delete-emptydir-data --force
kubectl delete node $NODE_NAME
ETCDCTL_API=3 etcdctl member remove $(etcdctl member list | grep $NODE_NAME | cut -d, -f1)
EOF

dnf -y install kernel-devel-$(uname -r)
rpm -i https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.rpm

rpm -Uvh https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
dnf -y install nano git puppet-agent socat

modprobe br_netfilter
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe overlay

cat <<EOF | tee /etc/modules-load.d/kubernetes.conf
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
overlay
EOF

cat <<EOF | tee /etc/sysctl.d/kubernetes.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

swapoff -a
sed -i '/swap/d' /etc/fstab

dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf makecache
dnf -y install containerd.io
sh -c "containerd config default > /etc/containerd/config.toml"
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl enable --now containerd.service



cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

dnf makecache; dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet.service

kubeadm config images pull

set +xv
cat <<EOF >> /home/ec2-user/Linas.pem
${ec2_key}
EOF
set -xv 
chmod 600 /home/ec2-user/Linas.pem

current_ip=$(hostname -I | awk '{print $1}')

if [[ "$current_ip" == "10.0.2.4" ]]; then
kubeadm init --control-plane-endpoint `hostname -I` \
--pod-network-cidr 11.0.0.0/16 \
--apiserver-advertise-address=`hostname -I` \
--service-cidr 10.0.0.1/16 \
--upload-certs
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
else
ssh-keyscan -H ${controller_hostname} >> ~/.ssh/known_hosts
ssh -i /home/ec2-user/Linas.pem ec2-user@${controller_hostname} "ansible-playbook /home/ec2-user/master_join_master.yaml -e second_master_ip=`hostname -I`"
fi
rm /home/ec2-user/Linas.pem

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sh ./get_helm.sh


export pupethost=`hostname`

cat <<EOF | tee /etc/puppetlabs/puppet/puppet.conf
[main]
certname = $pupethost
server = ${controller_hostname}
EOF

/opt/puppetlabs/bin/puppet ssl bootstrap
systemctl enable --now puppet

systemctl reboot
