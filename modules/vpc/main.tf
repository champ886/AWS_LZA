# -----------------------------------------------
# PROVIDER REQUIREMENTS
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
# DNS support and hostnames required for
# services like ECS, RDS and service discovery
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
# Required for public subnet internet access
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
# One per AZ with auto public IP assignment
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
# One per AZ with no direct internet access
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
# Single shared table for all public subnets
# Routes all internet traffic through the IGW
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
# PRIVATE ROUTE TABLES - ONE PER AZ
# Separate route tables per AZ allows intra-AZ
# routing over VPC peering connections
# Peering routes added by peering module later
# -----------------------------------------------
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-${var.account_name}-private-rt-${count.index + 1}"
    Environment = var.environment
    AZ          = var.availability_zones[count.index]
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------
# PUBLIC ROUTE TABLE ASSOCIATIONS
# Links each public subnet to the public route table
# -----------------------------------------------
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------
# PRIVATE ROUTE TABLE ASSOCIATIONS
# Each private subnet gets its own AZ route table
# Subnet 1 → AZ-a route table
# Subnet 2 → AZ-b route table
# -----------------------------------------------
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}