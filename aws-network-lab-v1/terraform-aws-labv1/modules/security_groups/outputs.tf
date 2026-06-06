output "web_sg_id" {
  description = "web-sg-tf1 ID — attached to web-server-tf1 EC2"
  value       = aws_security_group.web_sg.id
}

output "app_sg_id" {
  description = "app-sg-tf1 ID — attached to app-server-tf1 EC2"
  value       = aws_security_group.app_sg.id
}

output "db_sg_id" {
  description = "db-sg-tf1 ID — attached to db-server-tf1 EC2"
  value       = aws_security_group.db_sg.id
}