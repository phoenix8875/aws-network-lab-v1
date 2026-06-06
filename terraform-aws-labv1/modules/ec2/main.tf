# ─────────────────────────────────────────────
# WEB SERVER (web-server-tf1)
# Lives in: public subnet
# Has: public IP automatically (map_public_ip_on_launch = true in subnet)
# Security group: web-sg-tf1 (port 80 + 22 open to world)
# Role: Nginx reverse proxy — faces the internet
# ─────────────────────────────────────────────
resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.web_sg_id]
  key_name               = var.key_name

  tags = {
    Name = "${var.project_name}-web-server-tf1"
  }
}

# ─────────────────────────────────────────────
# APP SERVER (app-server-tf1)
# Lives in: private subnet (ap-south-1a)
# Has: NO public IP — completely hidden
# Security group: app-sg-tf1 (port 5000 + 22 only from web-sg)
# Role: Flask app — only reachable from web-server-tf1
# ─────────────────────────────────────────────
resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.app_subnet_id
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = var.key_name

  tags = {
    Name = "${var.project_name}-app-server-tf1"
  }
}

# ─────────────────────────────────────────────
# DB SERVER (db-server-tf1)
# Lives in: db-private subnet (ap-south-1b)
# Has: NO public IP — deepest private layer
# Security group: db-sg-tf1 (port 3306 + 22 only from app-sg)
# Role: MariaDB — only reachable from app-server-tf1
# ─────────────────────────────────────────────
resource "aws_instance" "db_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.db_subnet_id
  vpc_security_group_ids = [var.db_sg_id]
  key_name               = var.key_name

  tags = {
    Name = "${var.project_name}-db-server-tf1"
  }
}