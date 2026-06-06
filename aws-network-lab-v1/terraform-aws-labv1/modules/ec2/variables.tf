variable "project_name" {
  description = "Prefix for all EC2 instance names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for all EC2 instances — use Amazon Linux 2 for Mumbai"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type — t2.micro is free tier eligible"
  type        = string
}

variable "key_name" {
  description = "Name of the existing AWS key pair for SSH access"
  type        = string
}

# ── Subnet IDs from vpc module ──────────────────
variable "public_subnet_id" {
  description = "Public subnet ID — web-server-tf1 goes here"
  type        = string
}

variable "app_subnet_id" {
  description = "App private subnet ID — app-server-tf1 goes here"
  type        = string
}

variable "db_subnet_id" {
  description = "DB private subnet ID — db-server-tf1 goes here"
  type        = string
}

# ── Security Group IDs from security_groups module ──
variable "web_sg_id" {
  description = "web-sg-tf1 ID — attached to web-server-tf1"
  type        = string
}

variable "app_sg_id" {
  description = "app-sg-tf1 ID — attached to app-server-tf1"
  type        = string
}

variable "db_sg_id" {
  description = "db-sg-tf1 ID — attached to db-server-tf1"
  type        = string
}