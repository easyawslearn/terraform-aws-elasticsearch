variable "region" {
  description = "The AWS region to create resources in."
  default     = "eu-central-1"
}

variable "vpc_filter_name" {
  default = "-VPC/vpc"
}

variable "vpc" {
  default = "CloudStation"
}

variable "is_encrypt" {
  default = "true"
}

variable "app_name" {
  default = "elastic-service"
}

variable "instance_type" {
  default = "m4.xlarge.elasticsearch"
}

variable "instance_count" {
  default = "2"
}
variable "owner" {
  default = "demo"
}

variable "account" {
  default = "dev"
}

variable "automated_snapshot_start_hour" {
  description = "When we should take each snapshot"
  type        = "map"

  default = {
    "us-east-1"    = 5
    "us-east-2"    = 5
    "us-west-2"    = 8
    "eu-west-1"    = 2
    "eu-central-1" = 23
  }
}

variable "iam_roles_for_access" {
  type        = "list"
  description = "Roles with permissions to talk to this es domain (default no restrictions)"
  default     = ["*"]
}
