variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT'"
}

variable "stage" {
  type        = string
  default     = ""
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'"
}

variable "name" {
  type        = string
  default     = "review-apps"
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "A boolean string that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable"
}

variable "policy" {
  type        = string
  default     = ""
  description = "A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy"
}

variable "versioning_enabled" {
  type        = bool
  default     = true
  description = "A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket"
}

variable "sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms`"
}

variable "kms_master_key_arn" {
  type        = string
  default     = ""
  description = "The AWS KMS master key ARN used for the `SSE-KMS` encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default aws/s3 AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms`"
}

variable "domain_name" {
  type        = string
  description = "The domain used for review app deployments."
}

variable "route_53_zone_id" {
  type        = string
  description = "AWS Route 53 Zone Id used by"
}

variable "cloudfront_price_class" {
  type        = string
  default     = "PriceClass_100"
  description = "AWS CloudFront Price Class"
}

variable "lifecycle_rule_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable lifecycle rule"
}

variable "noncurrent_version_expiration_days" {
  type        = number
  default     = 30
  description = "Number of days to persist in the standard storage tier before moving to the infrequent access tier"
}

variable "expiration_days" {
  type        = number
  default     = 90
  description = "Specifies when objects expire"
}

variable "cloudfront_logging_config" {
  description = "The logging configuration that controls how logs are written to your distribution (maximum one)."
  type        = any
  default     = {}
}

variable "s3_logging_config" {
  description = "Map containing access bucket logging configuration."
  type        = map(string)
  default     = {}
}

variable "web_acl_id" {
  type        = string
  default     = null
  description = "The ID of the Amazon Web Services Web ACL to associate with the CloudFront distribution"
}

variable "tracing_config" {
  type        = string
  default     = null
  description = "The tracing mode to use for the Lambda functions"
}