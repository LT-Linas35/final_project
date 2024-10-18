# !!! ALL Commented out variables should be passed through TerraForm Cloud !!!
# Bastion server only for debugging; there is no other way to connect to the controller or to Kubernetes control plane or nodes.
# Kubernetes configuration will be downloaded to the $HOME/kube/.config on the controller instance after the first SSH login.


# AWS region
aws_region = "eu-west-2"

# Cluster Configuration
cluster = {
  CLUSTER_NAME = "k8s"       # The name of the Kubernetes cluster
  Environment  = "Dev"       # Environment type (e.g., Development, Production)
  ManagedBy    = "Terraform" # Indicates that Terraform manages the infrastructure
}

# Bastion Configuration
bastion = {
  ami                     = "ami-07d1e0a32156d0d21" # AMI ID for the bastion server
  instance_type           = "t2.micro"              # Instance type for the bastion server
  instance_name           = "bastion"               # Name tag for the bastion instance
  key_name                = "Linas-eu-out"          # SSH key pair name to access the bastion server
  map_public_ip_on_launch = true                    # Assign a public IP to the bastion server
  bastion_count           = 0                       # set to 1 for debugging
  volume_type             = "gp3"                   # EBS volume type for the bastion instance
  volume_size             = "10"                    # Size of the EBS volume in GiB
}

# Controller Instance Configuration
controller = {
  ami                     = "ami-07d1e0a32156d0d21" # AMI ID for the controller instance
  instance_type           = "t2.small"              # Instance type for the controller
  instance_name           = "controller"            # Name tag for the controller instance
  key_name                = "Linas"                 # SSH key pair name to access the controller
  map_public_ip_on_launch = true                    # Assign a public IP to the controller instance
  volume_type             = "gp3"                   # EBS volume type for the controller instance
  volume_size             = "10"                    # Size of the EBS volume in GiB
}

# Kubernetes Control Plane Configuration
k8s-master = {
  ami                     = "ami-07d1e0a32156d0d21" # AMI ID for Kubernetes master nodes
  instance_type           = "t2.medium"             # Instance type for the master nodes
  instance_name           = "k8s-masters"           # Name tag for the master nodes
  key_name                = "Linas"                 # SSH key pair name to access the master nodes
  map_public_ip_on_launch = false                   # Do not assign a public IP to master nodes
  k8s_master_count        = "1"                     # Number of master nodes
  volume_type             = "gp3"                   # EBS volume type for the master nodes
  volume_size             = "10"                    # Size of the EBS volume in GiB
  k8s-master_count        = 1                       # At the moment supported only one unless manualy added
}

# Kubernetes Nodes Configuration
k8s-nodes = {
  ami                     = "ami-07d1e0a32156d0d21" # AMI ID for Kubernetes nodes
  instance_type           = "t2.medium"             # Instance type for the nodes
  instance_name           = "k8s-nodes"             # Name tag for the nodes
  key_name                = "Linas"                 # SSH key pair name to access the nodes
  map_public_ip_on_launch = false                   # Do not assign a public IP to nodes
  k8s_node_count          = "2"                     # Number of nodes
  volume_type             = "gp3"                   # EBS volume type for the nodes
  volume_size             = "15"                    # Size of the EBS volume in GiB
  k8s-node_count          = 1
}

# AWS VPC Configuration for Kubernetes
k8s_vpc = {
  vpc_cidr_block                         = "10.0.0.0/16"       # CIDR block for the VPC
  vpc_name                               = "my-vpc"            # Name tag for the VPC
  bastion_subnet_cidr_block              = "10.0.4.0/24"       # CIDR block for the bastion subnet
  controller_subnet_cidr_block           = "10.0.3.0/24"       # CIDR block for the controller subnet
  master_subnet_cidr_block               = "10.0.2.0/24"       # CIDR block for the master nodes subnet
  nodes_subnet_cidr_block                = "10.0.1.0/24"       # CIDR block for the nodes subnet
  bastion_subnet_name                    = "bastion-subnet"    # Name tag for the bastion subnet
  controller_subnet_name                 = "controller-subnet" # Name tag for the controller subnet
  master_subnet_name                     = "master-subnet"     # Name tag for the master subnet
  nodes_subnet_name                      = "nodes-subnet"      # Name tag for the nodes subnet
  availability_zone                      = "eu-west-2a"        # Availability zone for the VPC resources
  enable_dns_hostnames                   = true                # Enable DNS hostnames in the VPC
  enable_dns_support                     = true                # Enable DNS support in the VPC
  public_nat_cidr_block                  = "0.0.0.0/0"         # CIDR block for public NAT gateway
  priv_route_table_nat_cidr_block        = "0.0.0.0/0"         # CIDR block for private route table with NAT
  alb1_alb_subnet_az1_name               = "ALB Subnet AZ1"    # Name tag for the first ALB subnet
  alb_subnet_az1_cidr_block              = "10.0.6.0/24"       # CIDR block for the first ALB subnet
  alb_subnet_az1_availability_zone       = "eu-west-2b"        # Availability zone for the first ALB subnet
  alb_subnet_az1_map_public_ip_on_launch = true                # Assign public IP on launch for the first ALB subnet
  alb2_alb_subnet_az2_name               = "ALB Subnet AZ2"    # Name tag for the second ALB subnet
  alb_subnet_az2_cidr_block              = "10.0.5.0/24"       # CIDR block for the second ALB subnet
  alb_subnet_az2_availability_zone       = "eu-west-2c"        # Availability zone for the second ALB subnet
  alb_subnet_az2_map_public_ip_on_launch = true                # Assign public IP on launch for the second ALB subnet
}

# RDS Configuration for NextCloud Database
rds = {
  Name              = "NextCloud"    # Name tag for the RDS instance
  allocated_storage = 20             # Amount of storage (in GiB) allocated to RDS
  db_name           = "nextcloud"    # Name of the database in the RDS instance
  engine            = "mysql"        # Database engine used by RDS
  engine_version    = "8.0"          # Version of the database engine
  instance_class    = "db.t4g.micro" # Instance class for the RDS instance
  //  username               = ""         # Username (pass through TerraForm Cloud or secret management)
  //  password               = ""         # Password (pass through TerraForm Cloud or secret management)
  parameter_group_name   = "default.mysql8.0"           # Parameter group for MySQL 8.0
  skip_final_snapshot    = true                         # Skip the final snapshot when deleting the RDS instance
  publicly_accessible    = false                        # Make the RDS instance private
  rds1_cidr_block        = "10.0.9.0/24"                # CIDR block for the first RDS subnet
  rds1_availability_zone = "eu-west-2a"                 # Availability zone for the first RDS subnet
  rds_name               = "RDS main subnet"            # Name tag for the RDS subnet
  rds2_cidr_block        = "10.0.8.0/24"                # CIDR block for the second RDS subnet
  rds2_availability_zone = "eu-west-2b"                 # Availability zone for the second RDS subnet
  db_subnet_group_name   = "nextcloud-rds-subnet-group" # Name of the RDS subnet group
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
  redis_subnet_cidr_block = "10.0.7.0/24"     # CIDR block for the Redis subnet
  redis_subnet_group_name = "redis-subnet"    # Name of the Redis subnet group
}

# NextCloud Installation Configuration
nextcloud_install = {
  //  ADMIN_USER     = ""          # Admin user for NextCloud (pass through TerraForm Cloud or secret management)
  //  ADMIN_PASSWORD = ""          # Admin password for NextCloud (pass through TerraForm Cloud or secret management)
  //  ADMIN_EMAIL    = ""          # Admin email for NextCloud (pass through TerraForm Cloud or secret management)
  REDIS_TIMEOUT = 0                # Redis timeout value for NextCloud
  REDIS_DBINDEX = 0                # Redis database index for NextCloud
  S3_BUCKET     = "lino-nextcloud" # S3 bucket name used for NextCloud storage
}
