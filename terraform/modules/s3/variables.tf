variable "kops_oidc_bucket_name" {
  description = "Bucket name for Kops OIDC store"
  type        = string
}

variable "kops_state_bucket_name" {
  description = "S3 bucket name to store the Kops cluster state files."
  type        = string
}

variable "s3_bucket_ownership_controls_oidc_store" {
  description = "Ownership controls for the S3 bucket used for OIDC store."
  type        = string
}

variable "s3_bucket_public_access_oidc_store_block_block_public_acls" {
  description = "Whether to block public ACLs for the OIDC store bucket."
  type        = bool
}

variable "s3_bucket_public_access_oidc_store_block_ignore_public_acls" {
  description = "Whether to ignore public ACLs for the OIDC store bucket."
  type        = bool
}

variable "s3_bucket_public_access_oidc_store_block_block_public_policy" {
  description = "Whether to block public policies for the OIDC store bucket."
  type        = bool
}

variable "s3_bucket_public_access_oidc_store_block_restrict_public_buckets" {
  description = "Whether to restrict public buckets for the OIDC store."
  type        = bool
}

variable "s3_bucket_acl_oidc_store_acl" {
  description = "ACL setting for the S3 bucket used for OIDC store."
  type        = string
}
