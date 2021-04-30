# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.sysname}-prod-vpc"
  }
}

# Internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

# Route config
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

# Route table association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_A1.id
  route_table_id = aws_route_table.public.id
}

# Public subnet
resource "aws_subnet" "public_A1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "${var.sysname}-prod-web-subnetA1"
  }
}
