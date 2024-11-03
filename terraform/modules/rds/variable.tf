variable "Cluster" {
  description = "The name of the Kubernetes cluster"
  type        = string
}

variable "Environment" {
  description = "The environment for the resources (e.g., Production, Development)"
  type        = string
}

variable "ManagedBy" {
  description = "The entity responsible for managing these resources"
  type        = string
}

variable "db_subnet_group_name" {
  description = "The name of the RDS subnet group for the NextCloud RDS instance."
  type        = string
}

variable "rds_sg" {
  description = "The security group ID to associate with the RDS instance."
  type        = string
}

variable "allocated_storage" {
  description = "The amount of storage (in GiB) to allocate for the RDS instance."
  type        = number
}

variable "db_name" {
  description = "The name of the database to create in the RDS instance."
  type        = string
}

variable "engine" {
  description = "The database engine to use for the RDS instance (e.g., mysql, postgres)."
  type        = string
}

variable "engine_version" {
  description = "The version of the database engine."
  type        = string
}

variable "instance_class" {
  description = "The instance class to use for the RDS instance (e.g., db.t4g.micro)."
  type        = string
}

variable "username" {
  description = "The master username for the RDS instance."
  type        = string
}

variable "password" {
  description = "The master password for the RDS instance."
  type        = string
}

variable "parameter_group_name" {
  description = "The name of the DB parameter group to associate with the RDS instance."
  type        = string
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the RDS instance."
  type        = bool
}

variable "publicly_accessible" {
  description = "Whether the RDS instance should be publicly accessible."
  type        = bool
}

variable "Name" {
  description = "The name of the RDS instance"
  type        = string
}

variable "storage_encrypted" {
  description = "Determines whether to enable storage encryption for the RDS instance."
  type        = bool
}
