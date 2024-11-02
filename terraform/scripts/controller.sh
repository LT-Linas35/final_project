#!/bin/bash

# Enable verbose mode and command tracing for debugging purposes
set -xv

# dnf -y update
# Upgrade all system packages to the latest version
# dnf -y upgrade

# Install necessary tools: Nano, Zsh, Git, jq, unzip
dnf -y install nano zsh git jq unzip # ansible-core.x86_64 pip

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/bin/kubectl
rm -rf kubectl

# Configure Ansible to disable host key checking and set SSH connection settings
#cat <<EOF > /etc/ansible/ansible.cfg
#[defaults]
#host_key_checking = False
#[ssh_connection]
#ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o IdentityFile=/home/ec2-user/.ssh/id_rsa
#EOF

# Install Helm, a Kubernetes package manager
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sh ./get_helm.sh
ln -s /usr/local/bin/helm /usr/bin/

# Install k9s, a CLI tool for managing Kubernetes clusters
rpm -i https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.rpm

# Install Oh My Zsh for a better terminal experience
sudo -u ec2-user sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo -u root sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

usermod -s /usr/bin/zsh ec2-user
usermod -s /usr/bin/zsh root

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --bin-dir /usr/bin --install-dir /usr/aws-cli
rm -rf awscliv2.zip ./aws

# Configure AWS credentials and region
sudo -u ec2-user mkdir /home/ec2-user/.aws
sudo -u ec2-user cat << EOF > /home/ec2-user/.aws/config
[default]
region = ${KOPS_REGION}
output = json
EOF
sudo -u ec2-user cat << EOF > /home/ec2-user/.aws/credentials
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF

# Install kOps for Kubernetes cluster management
curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops
mv kops /usr/bin/kops

# kOps cluster setup script
sudo -u ec2-user cat << EOF > /home/ec2-user/kops.sh 
#!/bin/bash
export NAME=${Cluster}.k8s.local
export KOPS_STATE_STORE=s3://${kops_state_bucket_name}
export ZONES=\$(aws ec2 describe-availability-zones --region ${KOPS_REGION} | jq -r '.AvailabilityZones[0].ZoneName')
export VPC_ID=${KOPS_VPC_ID}
export NETWORK_CIDR=10.0.0.0/16

kops create cluster --name=\$NAME --cloud=aws --zones=\$ZONES \
--discovery-store=s3://${kops_oidc_bucket_name}/\$NAME/discovery --network-id=\$VPC_ID \
--subnets=${kops_subnet_id} --utility-subnets=${kops_utility_subnet_id} --node-size=${NODE_SIZE} \
--node-count=${NODE_COUNT} --control-plane-size=${CONTROL_PLANE_SIZE} \
--control-plane-count=${CONTROL_PLANE_COUNT} --topology=${KOPS_TOPOLOGY} \
--api-loadbalancer-type=${KOPS_NLB} --networking=amazonvpc

kops update cluster --name \$NAME --yes --admin
kops validate cluster --wait 15m
EOF
sudo -u ec2-user bash /home/ec2-user/kops.sh

# Install ArgoCD
VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/bin/argocd
rm argocd-linux-amd64

# Install Ingress-Nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx

# Set up ArgoCD and expose as LoadBalancer
sudo -u ec2-user helm repo add argo https://argoproj.github.io/argo-helm
sudo -u ec2-user helm install argocd argo/argo-cd
sudo -u ec2-user kubectl patch svc argocd-server -p '{"spec": {"type": "LoadBalancer"}}'

sleep 120 # Waiting for LoadBalancer to be ready

export ARGOCD_SERVER_ADDRESS=$(sudo -u ec2-user kubectl get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'; echo)
export ADMIN_PASSWORD=$(sudo -u ec2-user kubectl get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode; echo)

# Login to ArgoCD
sudo -u ec2-user argocd login $ARGOCD_SERVER_ADDRESS --username admin --password $ADMIN_PASSWORD --insecure

# Install Argo Rollouts
sudo -u ec2-user kubectl create ns argo-rollouts
sudo -u ec2-user kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# Install kubectl-argo-rollouts plugin
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x ./kubectl-argo-rollouts-linux-amd64
mv ./kubectl-argo-rollouts-linux-amd64 /usr/bin/kubectl-argo-rollouts

# Install ArgoCD Image Updater
sudo -u ec2-user kubectl apply -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml

# Install NewRelic monitoring with Helm
sudo -u ec2-user helm repo add newrelic https://helm-charts.newrelic.com 
sudo -u ec2-user helm repo update 
sudo -u ec2-user kubectl create namespace newrelic 
sudo -u ec2-user helm upgrade --install newrelic-bundle newrelic/nri-bundle --namespace=newrelic \
--set global.licenseKey=${newrelic_global_licenseKey} \
--set global.cluster=${Cluster}.k8s.local \
--set newrelic-infrastructure.privileged=true \
--set global.lowDataMode=true \
--set kube-state-metrics.image.tag=${KSM_IMAGE_VERSION} \
--set kube-state-metrics.enabled=true \
--set kubeEvents.enabled=true \
--set newrelic-prometheus-agent.enabled=true \
--set newrelic-prometheus-agent.lowDataMode=true \
--set newrelic-prometheus-agent.config.kubernetes.integrations_filter.enabled=false \
--set logging.enabled=true \
--set newrelic-logging.lowDataMode=true

# Set up Nextcloud with ArgoCD
sudo -u ec2-user kubectl create ns nextcloud
sudo -u ec2-user argocd app create nextcloud-rollout \
--repo https://github.com/LT-Linas35/final_project \
--path helm-charts/nextcloud-chart \
--dest-server https://kubernetes.default.svc \
--dest-namespace nextcloud \
--sync-policy automated \
--helm-set database.type=${DATABASE_TYPE} \
--helm-set database.name=${DATABASE_NAME} \
--helm-set database.host=${DATABASE_HOST} \
--helm-set database.port=${DATABASE_PORT} \
--helm-set database.user=${DATABASE_USER} \
--helm-set database.password=${DATABASE_PASSWORD} \
--helm-set admin.user=${ADMIN_USER} \
--helm-set admin.password=${ADMIN_PASSWORD} \
--helm-set admin.email=${ADMIN_EMAIL} \
--helm-set redis.host=${REDIS_HOST} \
--helm-set redis.port=${REDIS_PORT} \
--helm-set redis.timeout=${REDIS_TIMEOUT} \
--helm-set redis.dbindex=${REDIS_DBINDEX} \
--helm-set s3.bucket=${S3_NEXTCLOUD_BUCKET} \
--helm-set s3.region=${S3_NEXTCLOUD_REGION} \
--helm-set s3.key=${S3_USER_KEY} \
--helm-set s3.secret=${S3_USER_SECRET} \
--helm-set canarySteps[0].setWeight=${canarySteps_0_setWeight} \
--helm-set canarySteps[0].pauseDuration=${canarySteps_0_pauseDuration} \
--helm-set canarySteps[1].setWeight=${canarySteps_1_setWeight} \
--helm-set canarySteps[1].pauseDuration=${canarySteps_1_pauseDuration} \
--helm-set canarySteps[2].setWeight=${canarySteps_2_setWeight}





#curl -s https://api.github.com/repos/LT-Linas35/final_project/contents/server | grep download_url | cut -d '"' -f 4 | while read url; do
#  curl -O "$url"
#done

# Reboot the system to apply changes
#systemctl reboot
