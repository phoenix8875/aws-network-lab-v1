# ─────────────────────────────────────────────
# WEB SECURITY GROUP (web-sg-tf1)
# Attached to: web-server-tf1
# Allows: HTTP from internet, SSH from anywhere
# ─────────────────────────────────────────────
resource "aws_security_group" "web_sg" {
  name        = "web-sg-tf1"
  description = "Web tier - allows HTTP and SSH from internet"
  vpc_id      = var.vpc_id

  # Allow HTTP from anywhere — public users hit this
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from anywhere — admin access to web server
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg-tf1"
  }
}

# ─────────────────────────────────────────────
# APP SECURITY GROUP (app-sg-tf1)
# Attached to: app-server-tf1
# Key concept: rules reference web_sg ID directly
# NOT a CIDR range — this is security group chaining
# ─────────────────────────────────────────────
resource "aws_security_group" "app_sg" {
  name        = "app-sg-tf1"
  description = "App tier - only accepts traffic from web-sg-tf1"
  vpc_id      = var.vpc_id

  # Flask port 5000 — only from web-server-tf1
  # security_groups = [id] means ONLY instances
  # wearing web_sg can reach this port
  ingress {
    description     = "Flask from web-sg only"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # SSH — only jumpable from web-server-tf1
  ingress {
    description     = "SSH via web-sg jumpbox only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg-tf1"
  }
}

# ─────────────────────────────────────────────
# DB SECURITY GROUP (db-sg-tf1)
# Attached to: db-server-tf1
# Strictest group — only app-sg can talk to it
# Nobody else can even see port 3306 exists
# ─────────────────────────────────────────────
resource "aws_security_group" "db_sg" {
  name        = "db-sg-tf1"
  description = "DB tier - only accepts traffic from app-sg-tf1"
  vpc_id      = var.vpc_id

  # MySQL port 3306 — only from app-server-tf1
  ingress {
    description     = "MySQL from app-sg only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  # SSH — only jumpable from app-server-tf1
  ingress {
    description     = "SSH via app-sg jumpbox only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg-tf1"
  }
}