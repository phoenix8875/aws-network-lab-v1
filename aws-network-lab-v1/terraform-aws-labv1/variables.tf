variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "project_name" {
  description = "Prefix for all resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet — web-server-tf1"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets [app, db]"
  type        = list(string)
}

variable "availability_zones" {
  description = "AZs for Mumbai [ap-south-1a, ap-south-1b]"
  type        = list(string)
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID for ap-south-1"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Existing AWS key pair name"
  type        = string
}