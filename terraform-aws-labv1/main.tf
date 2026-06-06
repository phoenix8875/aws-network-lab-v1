# ─────────────────────────────────────────────
# PROVIDER
# Tells Terraform we are using AWS
# and which region to deploy into
# ─────────────────────────────────────────────
provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────────
# MODULE: VPC
# Creates VPC, subnets, IGW, route tables
# Exposes: vpc_id, subnet ids
# ─────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# ─────────────────────────────────────────────
# MODULE: SECURITY GROUPS
# Creates web-sg, app-sg, db-sg
# Needs vpc_id from vpc module
# Exposes: sg ids
# ─────────────────────────────────────────────
module "security_groups" {
  source = "./modules/security_groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id        # ← output from vpc module
}

# ─────────────────────────────────────────────
# MODULE: EC2
# Creates web, app, db servers
# Needs subnet ids from vpc module
# Needs sg ids from security_groups module
# ─────────────────────────────────────────────
module "ec2" {
  source = "./modules/ec2"

  project_name     = var.project_name
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  key_name         = var.key_name

  # From vpc module
  public_subnet_id = module.vpc.public_subnet_id
  app_subnet_id    = module.vpc.app_subnet_id
  db_subnet_id     = module.vpc.db_subnet_id

  # From security_groups module
  web_sg_id        = module.security_groups.web_sg_id
  app_sg_id        = module.security_groups.app_sg_id
  db_sg_id         = module.security_groups.db_sg_id
}