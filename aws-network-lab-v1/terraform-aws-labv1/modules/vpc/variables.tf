variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR for the single public subnet (web tier)"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets [app, db]"
  type        = list(string)
}

variable "availability_zones" {
  description = "AZs to place subnets in [ap-south-1a, ap-south-1b]"
  type        = list(string)
}

variable "project_name" {
  description = "Prefix for all resource names e.g. myproject"
  type        = string
}