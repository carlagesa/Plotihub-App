resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# Internet Gateway for public subnets
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# --- Public Subnets ---
# For Application Load Balancer - in different AZs for High Availability

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 10) # e.g., 10.0.10.0/24
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 11) # e.g., 10.0.11.0/24
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-b"
  }
}

# --- Private Subnets ---
# For EC2 instances (EB) and RDS - in different AZs for HA

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 0) # e.g., 10.0.0.0/24
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.environment}-private-subnet-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 1) # e.g., 10.0.1.0/24
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.environment}-private-subnet-b"
  }
}

# --- Route Tables ---

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_a" {
  subnet_id       = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id       = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway for private subnets (allows EC2 to access internet)
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id    = aws_subnet.public_a.id

  tags = {
    Name = "${var.environment}-nat-gw"
  }
  
  depends_on = [aws_internet_gateway.main]
}

# Private route table (via NAT Gateway)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-private-rt"
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private_a" {
  subnet_id       = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id       = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
