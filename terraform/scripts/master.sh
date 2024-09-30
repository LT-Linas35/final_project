#!/bin/bash

set -xv 

systemctl stop sshd

cat <<EOF > /etc/systemd/system/k8s-masters-cleanup.service
[Unit]
Description=Remove Kubernetes masters from cluster before shutdown
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

chmod +x /etc/systemd/system/k8s-masters-cleanup.service


cat <<EOF > /usr/local/bin/k8s-master-cleanup.sh
#!/bin/bash
export KUBECONFIG=/etc/kubernetes/admin.conf
NODE_NAME=\$(hostname)
kubectl drain \$NODE_NAME --ignore-daemonsets --delete-emptydir-data --force
kubectl delete node \$NODE_NAME
ETCDCTL_API=3 etcdctl member remove \$(etcdctl member list | grep \$NODE_NAME | cut -d, -f1)
EOF


chmod +x /usr/local/bin/k8s-master-cleanup.sh


#systemctl daemon-reload
#systemctl enable --now k8s-master-cleanup.service

dnf -y install kernel-devel-$(uname -r)

rpm -i https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.rpm

rpm -Uvh https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
dnf -y install nano git puppet-agent socat wget

modprobe br_netfilter
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe overlay

cat <<EOF > /etc/modules-load.d/kubernetes.conf
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
overlay
EOF

cat <<EOF > /etc/sysctl.d/kubernetes.conf
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


# Calico not working with this repo
#cat <<EOF > /etc/yum.repos.d/kubernetes.repo
#[kubernetes]
#name=Kubernetes
#baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
#enabled=1
#gpgcheck=1
#gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
#exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
#EOF

# At the moment then Im writing this message Flannel not working with this repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
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
cat <<EOF >  /home/ec2-user/Linas.pem

EOF

set -xv 
chmod 600 /home/ec2-user/Linas.pem


kubeadm init --control-plane-endpoint $(hostname -I) --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=$(hostname -I) --service-cidr=10.96.0.0/12 --upload-certs


export KUBECONFIG=/etc/kubernetes/admin.conf

#kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml
#curl -o /home/ec2-user/custom-resources.yaml https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml
#sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.244.0.0\/16/g' /home/ec2-user/custom-resources.yaml
#kubectl apply -f /home/ec2-user/custom-resources.yaml

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sed -i 's|/usr/local/bin|/usr/bin|' get_helm.sh
sh ./get_helm.sh

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.3/cert-manager.crds.yaml
## Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io --force-update

## Install the cert-manager helm chart
helm install cert-manager --namespace cert-manager --version v1.15.3 jetstack/cert-manager
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=k8s -n kube-system


cat <<EOF >  /home/ec2-user/nextcloud-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nextcloud
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nextcloud
  template:
    metadata:
      labels:
        app: nextcloud
    spec:
      containers:
      - name: nextcloud-container
        image: linas37/nextcloud:latest  
        ports:
        - containerPort: 80
EOF

#kubectl apply -f /home/ec2-user/nextcloud-deployment.yaml

cat <<EOF >  /home/ec2-user/nextcloud-service.yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: nextcloud
  name: nextcloud-service
spec:
  ports:
  - name: 80-80
    port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: nextcloud
  type: LoadBalancer
status:
  loadBalancer: {}
EOF

#kubectl apply -f /home/ec2-user/nextcloud-service.yaml

cat <<EOF >  /home/ec2-user/nextcloud-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: instance
  finalizers:
  - ingress.k8s.aws/resources
  generation: 2
  name: nextcloud-ingress
  namespace: default
spec:
  ingressClassName: alb
  rules:
  - http:
      paths:
      - backend:
          service:
            name: nextcloud-service
            port:
              number: 80
        path: /
        pathType: Prefix
status:
  loadBalancer: {}
EOF

#kubectl apply -f /home/ec2-user/nextcloud-ingress.yaml

export pupethost=$(hostname | awk '{print $1}')

cat <<EOF > /etc/puppetlabs/puppet/puppet.conf
[main]
certname = $pupethost
server = ${controller_hostname}
EOF

/opt/puppetlabs/bin/puppet ssl bootstrap
systemctl enable puppet


systemctl reboot


