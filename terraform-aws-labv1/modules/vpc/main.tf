# ─────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc-tf1"
  }
}

# ─────────────────────────────────────────────
# PUBLIC SUBNET — web-server-tf1 lives here
# ─────────────────────────────────────────────
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-tf1"
  }
}

# ─────────────────────────────────────────────
# PRIVATE SUBNETS — app + db live here
# index 0 → app-private-tf1  (ap-south-1a)
# index 1 → db-private-tf1   (ap-south-1b)
# ─────────────────────────────────────────────
resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${count.index == 0 ? "private" : "db-private"}-tf1"
  }
}

# ─────────────────────────────────────────────
# INTERNET GATEWAY
# Door between VPC and internet
# Only public subnet uses this
# ─────────────────────────────────────────────
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw-tf1"
  }
}

# ─────────────────────────────────────────────
# ELASTIC IP — required by NAT Gateway
# Static public IP allocated for NAT to use
# ─────────────────────────────────────────────
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-tf1"
  }
}

# ─────────────────────────────────────────────
# NAT GATEWAY
# Lives in public subnet
# Gives private servers outbound internet only
# Internet cannot initiate inbound ✅
#
# ⚠️  COST: ~$32/month + data charges
# Run terraform destroy when done testing
# ─────────────────────────────────────────────
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-nat-tf1"
  }
}

# ─────────────────────────────────────────────
# PUBLIC ROUTE TABLE
# 0.0.0.0/0 → IGW
# ─────────────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt-tf1"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ─────────────────────────────────────────────
# PRIVATE ROUTE TABLE
# 0.0.0.0/0 → NAT Gateway
# app + db servers get outbound internet
# but no inbound from internet possible
# ─────────────────────────────────────────────
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt-tf1"
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}