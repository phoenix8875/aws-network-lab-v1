variable "vpc_id" {
  description = "VPC ID from vpc module — scopes all security groups to our VPC"
  type        = string
}

variable "project_name" {
  description = "Prefix for all security group names"
  type        = string
}