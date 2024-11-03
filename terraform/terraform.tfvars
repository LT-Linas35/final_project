# !!! ALL Commented out variables should be passed through TerraForm Cloud !!!
# Bastion server only for debugging; there is no other way to connect to the controller.


# AWS region

aws_region = "eu-west-2"

newrelic = {
  newrelic_global_licenseKey = ""            # Global New Relic license key for monitoring and observability.
  KSM_IMAGE_VERSION          = "v2.10.0"     # Version of the KSM (Kubernetes State Metrics) image to be deployed.
}


# NextCloud Installation Configuration

nextcloud_install = {
  ADMIN_USER     = ""               # Admin user for NextCloud (pass through TerraForm Cloud or secret management)
  ADMIN_PASSWORD = ""               # Admin password for NextCloud (pass through TerraForm Cloud or secret management)
  ADMIN_EMAIL    = ""               # Admin email for NextCloud (pass through TerraForm Cloud or secret management)
  REDIS_TIMEOUT  = 0                # Redis timeout value for NextCloud
  REDIS_DBINDEX  = 0                # Redis database index for NextCloud
  S3_BUCKET      = "lino-nextcloud" # S3 bucket name used for NextCloud storage
}

# This configuration defines the canary deployment strategy steps for ArgoCD Rollout.
# Each step includes a weight percentage and optional pause duration.

canary = {
  canarySteps_0_setWeight     = 25     # Weight percentage for the first canary step
  canarySteps_0_pauseDuration = "360s" # Pause duration after the first canary step

  canarySteps_1_setWeight     = 50     # Weight percentage for the second canary step
  canarySteps_1_pauseDuration = "360s" # Pause duration after the second canary step

  canarySteps_2_setWeight = 100 # Final weight percentage for full deployment
}


# Bastion Configuration

bastion = {
  ami                     = "ami-07d1e0a32156d0d21" # AMI ID for the bastion server
  instance_type           = "t2.micro"              # Instance type for the bastion server
  instance_name           = "bastion"               # Name tag for the bastion instance
  key_name                = "Linas-eu-out"          # SSH key pair name to access the bastion server
  map_public_ip_on_launch = true                    # Assign a public IP to the bastion server
  create_bastion          = 0                       # Flag to determine if the bastion host should be created (1/0)
  volume_type             = "gp3"                   # EBS volume type for the bastion instance
  volume_size             = "10"                    # Size of the EBS volume in GiB
}

# Controller Instance Configuration

controller = {
  ami                     = "ami-07d1e0a32156d0d21" # AMI ID for the controller instance
  instance_type           = "t2.micro"              # Instance type for the controller
  instance_name           = "controller"            # Name tag for the controller instance
  key_name                = "Linas"                 # SSH key pair name to access the controller
  map_public_ip_on_launch = false                   # Assign a public IP to the controller instance
  volume_type             = "gp3"                   # EBS volume type for the controller instance
  volume_size             = "10"                    # Size of the EBS volume in GiB
}

# Cluster Configuration

cluster = {
  CLUSTER_NAME               = "nextcloud"                       # The name of the Kubernetes cluster
  Environment                = "Dev"                             # Specifies the environment type (e.g., Dev, Staging, Production)
  ManagedBy                  = "Terraform"                       # Indicates that Terraform is managing the infrastructure
  kops_state_bucket_name     = "lino-nextcloud-kops-state-store" # S3 bucket name to store Kops cluster state
  kops_oidc_bucket_name      = "lino-nextcloud-kops-oidc-store"  # S3 bucket name for OpenID Connect (OIDC) configurations
  kops_subnet_cidr_block     = "10.0.1.0/24"                     # CIDR block for the primary Kops subnet where nodes are launched
  kops_subnet_name           = "kops"                            # Name of the subnet where Kops nodes are deployed
  kops_ip_on_launch          = false                             # Specifies if public IP addresses are assigned to nodes on launch
  NODE_SIZE                  = "t2.medium"                       # Instance type for Kubernetes worker nodes
  NODE_COUNT                 = 2                                 # Number of worker nodes in the cluster
  CONTROL_PLANE_SIZE         = "t2.medium"                       # Instance type for control plane (master) nodes
  CONTROL_PLANE_COUNT        = 1                                 # Number of control plane (master) nodes in the cluster
  kops_nlb_subnet_cidr_block = "10.0.2.0/24"                     # CIDR block for the Network Load Balancer (NLB) subnet
  kops_nlb_subnet_name       = "Kops NLB"                        # Name of the subnet for the Kops Network Load Balancer
  KOPS_TOPOLOGY              = "private"                         # Specifies topology for the Kops cluster; "private" means no public IPs for nodes
  KOPS_NLB                   = "internal"                        # Load balancer type for Kops; "internal" creates an internal NLB
  ARGOCD_PASSWORD            = ""                                # New ArgoCD password to login
}


# S3 bucket configuration settings for ownership, public access control, and ACL permissions.

s3 = {
  s3_bucket_ownership_controls_oidc_store                          = "BucketOwnerPreferred" # Specifies ownership control, "BucketOwnerPreferred" assigns ownership to the bucket owner.
  s3_bucket_public_access_oidc_store_block_block_public_acls       = false                  # Set to "true" to block public ACLs; "false" allows public ACLs for the bucket.
  s3_bucket_public_access_oidc_store_block_ignore_public_acls      = false                  # When "true", ignores any public ACLs on this bucket.
  s3_bucket_public_access_oidc_store_block_block_public_policy     = false                  # Set to "true" to block public bucket policies, preventing public access policies.
  s3_bucket_public_access_oidc_store_block_restrict_public_buckets = false                  # When "true", restricts public bucket policies; "false" allows public policies.
  s3_bucket_acl_oidc_store_acl                                     = "public-read"          # Sets the bucket's ACL; "public-read" permits public read access.
}


# AWS VPC Configuration for Kubernetes

k8s_vpc = {
  vpc_cidr_block                                = "10.0.0.0/16"                  # CIDR block for the entire VPC
  vpc_name                                      = "NextCloud-VPC"                # Name assigned to the VPC for identification
  bastion_subnet_cidr_block                     = "10.0.4.0/24"                  # CIDR block for the bastion subnet, typically used for secure access
  controller_subnet_cidr_block                  = "10.0.3.0/24"                  # CIDR block for the controller subnet, used for control plane resources
  bastion_subnet_name                           = "bastion"                      # Name tag for the bastion subnet for easy identification
  controller_subnet_name                        = "controller"                   # Name tag for the controller subnet for easy identification
  availability_zone                             = "eu-west-2a"                   # Availability zone where VPC resources will be created
  enable_dns_hostnames                          = true                           # Enables DNS hostnames within the VPC
  enable_dns_support                            = true                           # Enables DNS support within the VPC for enhanced networking
  public_nat_cidr_block                         = "0.0.0.0/0"                    # CIDR block allowing all outbound traffic for public NAT gateway
  priv_route_table_nat_cidr_block               = "0.0.0.0/0"                    # CIDR block allowing outbound traffic for private subnet via NAT
  internet_gateway_nextcloud_igw_name           = "nextcloud-igw"                # Name for the internet gateway attached to the VPC
  route_table_nextcloud_public_name             = "public"                       # Name for the public route table associated with the VPC
  nat_gateway_nat_gateway_name                  = "nextcloud-nat-gateway"        # Name for the NAT gateway in the public subnet
  route_table_private_route_table_with_nat_name = "private-route-table-with-nat" # Name for private route table using NAT for outbound traffic
}


# RDS Configuration for NextCloud Database
rds = {
  Name                        = "NextCloud"                  # Name tag for the RDS instance
  allocated_storage           = 20                           # Amount of storage (in GiB) allocated to RDS
  db_name                     = "nextcloud"                  # Name of the database in the RDS instance
  engine                      = "mysql"                      # Database engine used by RDS
  engine_version              = "8.0"                        # Version of the database engine
  instance_class              = "db.t4g.micro"               # Instance class for the RDS instance
  username                    = ""                           # Username (pass through TerraForm Cloud or secret management)
  password                    = ""                           # Password (pass through TerraForm Cloud or secret management)
  parameter_group_name        = "default.mysql8.0"           # Parameter group for MySQL 8.0
  skip_final_snapshot         = true                         # Skip the final snapshot when deleting the RDS instance
  publicly_accessible         = false                        # Make the RDS instance private
  rds1_cidr_block             = "10.0.6.0/24"                # CIDR block for the first RDS subnet
  rds1_availability_zone      = "eu-west-2a"                 # Availability zone for the first RDS subnet
  rds_name                    = "RDS main subnet"            # Name tag for the RDS subnet
  rds2_cidr_block             = "10.0.7.0/24"                # CIDR block for the second RDS subnet
  rds2_availability_zone      = "eu-west-2b"                 # Availability zone for the second RDS subnet
  db_subnet_group_name        = "nextcloud-rds-subnet-group" # Name of the RDS subnet group
  db_subnet_group_description = "Database subnet group for Nextcloud RDS deployment"
}

# Redis Configuration for Caching
redis = {
  cluster_id              = "nextcloud"       # Redis cluster ID
  engine                  = "redis"           # Cache engine (Redis)
  node_type               = "cache.t4g.micro" # Redis node type
  num_cache_nodes         = 1                 # Number of Redis cache nodes
  parameter_group_name    = "default.redis7"  # Redis parameter group for version 7
  port                    = 6379              # Port on which Redis will accept connections
  name                    = "redis"           # Name tag for the Redis cluster
  redis_subnet_cidr_block = "10.0.5.0/24"     # CIDR block for the Redis subnet
  redis_subnet_group_name = "redis"           # Name of the Redis subnet group
}
