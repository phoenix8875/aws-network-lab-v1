output "web_server_public_ip" {
  description = "Public IP of web-server-tf1 — use this to hit the app in browser"
  value       = aws_instance.web_server.public_ip
}

output "web_server_id" {
  description = "Instance ID of web-server-tf1"
  value       = aws_instance.web_server.id
}

output "app_server_private_ip" {
  description = "Private IP of app-server-tf1 — used for SSH jump and Flask config"
  value       = aws_instance.app_server.private_ip
}

output "app_server_id" {
  description = "Instance ID of app-server-tf1"
  value       = aws_instance.app_server.id
}

output "db_server_private_ip" {
  description = "Private IP of db-server-tf1 — used for MariaDB connection string"
  value       = aws_instance.db_server.private_ip
}

output "db_server_id" {
  description = "Instance ID of db-server-tf1"
  value       = aws_instance.db_server.id
}