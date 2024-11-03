resource "aws_instance" "controller" {
  instance_type          = var.instance_type
  ami                    = var.ami
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.aws_securitygroup_controller_sg_id]
  user_data              = data.template_file.user_data.rendered

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = {
    Name        = var.instance_name
    Cluster     = var.Cluster
    Environment = var.Environment
    ManagedBy   = var.ManagedBy
  }
}


data "template_file" "user_data" {
  template = file("./scripts/controller.sh")

  vars = {
    DATABASE_TYPE               = var.DATABASE_TYPE
    DATABASE_NAME               = var.DATABASE_NAME
    DATABASE_HOST               = var.DATABASE_HOST
    DATABASE_PORT               = var.DATABASE_PORT
    DATABASE_USER               = var.DATABASE_USER
    DATABASE_PASSWORD           = var.DATABASE_PASSWORD
    ADMIN_USER                  = var.ADMIN_USER
    ADMIN_PASSWORD              = var.ADMIN_PASSWORD
    ADMIN_EMAIL                 = var.ADMIN_EMAIL
    REDIS_HOST                  = var.REDIS_HOST
    REDIS_PORT                  = var.REDIS_PORT
    REDIS_TIMEOUT               = var.REDIS_TIMEOUT
    REDIS_DBINDEX               = var.REDIS_DBINDEX
    S3_NEXTCLOUD_BUCKET         = var.S3_NEXTCLOUD_BUCKET
    S3_NEXTCLOUD_REGION         = var.S3_NEXTCLOUD_REGION
    AWS_ACCESS_KEY_ID           = var.KOPS_AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY       = var.KOPS_AWS_SECRET_ACCESS_KEY
    kops_state_bucket_name      = var.kops_state_bucket_name
    kops_oidc_bucket_name       = var.kops_oidc_bucket_name
    KOPS_REGION                 = var.KOPS_REGION
    KOPS_VPC_ID                 = var.VPC_ID
    Cluster                     = var.Cluster
    kops_subnet_id              = var.kops_subnet_id
    NODE_SIZE                   = var.NODE_SIZE
    NODE_COUNT                  = var.NODE_COUNT
    CONTROL_PLANE_SIZE          = var.CONTROL_PLANE_SIZE
    CONTROL_PLANE_COUNT         = var.CONTROL_PLANE_COUNT
    kops_utility_subnet_id      = var.kops_utility_subnet_id
    KOPS_TOPOLOGY               = var.KOPS_TOPOLOGY
    KOPS_NLB                    = var.KOPS_NLB
    newrelic_global_licenseKey  = var.newrelic_global_licenseKey
    KSM_IMAGE_VERSION           = var.KSM_IMAGE_VERSION
    S3_USER_SECRET              = var.S3_USER_SECRET
    S3_USER_KEY                 = var.S3_USER_KEY
    canarySteps_0_setWeight     = var.canarySteps_0_setWeight
    canarySteps_0_pauseDuration = var.canarySteps_0_pauseDuration
    canarySteps_1_setWeight     = var.canarySteps_1_setWeight
    canarySteps_1_pauseDuration = var.canarySteps_1_pauseDuration
    canarySteps_2_setWeight     = var.canarySteps_2_setWeight
    ARGOCD_PASSWORD             = var.ARGOCD_PASSWORD
  }
}
