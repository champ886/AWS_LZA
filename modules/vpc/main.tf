# -----------------------------------------------
# PROVIDER REQUIREMENTS
# Provider is passed in from the calling environment
# allowing this module to deploy into different accounts
# -----------------------------------------------
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# -----------------------------------------------
# VPC
# DNS support and hostnames are required for
# services like ECS, RDS, and service discovery
# -----------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-${var.account_name}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------
# INTERNET GATEWAY
# Required for resources in public subnets
# to send and receive internet traffic
# -----------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-${var.account_name}-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------
# PUBLIC SUBNETS
# One subnet per availability zone
# map_public_ip_on_launch auto assigns public IPs
# -----------------------------------------------
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${var.account_name}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Public"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------
# PRIVATE SUBNETS
# One subnet per availability zone
# No direct internet access — protected from
# inbound internet traffic by design
# -----------------------------------------------
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.environment}-${var.account_name}-private-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Private"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------
# PUBLIC ROUTE TABLE
# Routes all internet traffic to the IGW
# Associated with all public subnets
# -----------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-${var.account_name}-public-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------
# PRIVATE ROUTE TABLE
# No internet route by default
# Add a NAT gateway route here if outbound
# internet access is needed from private subnets
# -----------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-${var.account_name}-private-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------
# PUBLIC ROUTE TABLE ASSOCIATIONS
# Links each public subnet to the public route table
# Without this subnets use the default VPC route table
# -----------------------------------------------
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------
# PRIVATE ROUTE TABLE ASSOCIATIONS
# Links each private subnet to the private route table
# -----------------------------------------------
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}