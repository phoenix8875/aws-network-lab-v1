# ─────────────────────────────────────────────
# These print to your terminal after
# terraform apply completes
# ─────────────────────────────────────────────

output "web_server_public_ip" {
  description = "Paste this in your browser to hit the app"
  value       = module.ec2.web_server_public_ip
}

output "web_server_id" {
  description = "web-server-tf1 instance ID"
  value       = module.ec2.web_server_id
}

output "app_server_private_ip" {
  description = "SSH jump target — app-server-tf1"
  value       = module.ec2.app_server_private_ip
}

output "app_server_id" {
  description = "app-server-tf1 instance ID"
  value       = module.ec2.app_server_id
}

output "db_server_private_ip" {
  description = "MariaDB host — use in Flask connection string"
  value       = module.ec2.db_server_private_ip
}

output "db_server_id" {
  description = "db-server-tf1 instance ID"
  value       = module.ec2.db_server_id
}

output "vpc_id" {
  description = "VPC ID for reference"
  value       = module.vpc.vpc_id
}