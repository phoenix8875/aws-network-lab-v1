output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "app_subnet_id" {
  value = aws_subnet.private[0].id
}

output "db_subnet_id" {
  value = aws_subnet.private[1].id
}