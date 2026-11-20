# Create the VPC
resource "aws_vpc" "fitbyte_vpc" {
  cidr_block = "10.0.0.0/16"
}

# === Create the subnets ===
resource "aws_subnet" "fitbyte_public_a" {
  vpc_id                  = aws_vpc.fitbyte_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "fitbyte_public"
  }
}

resource "aws_subnet" "fitbyte_private_a" {
  vpc_id                  = aws_vpc.fitbyte_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "fitbyte_private"
  }
}

resource "aws_subnet" "fitbyte_private_b" {
  vpc_id                  = aws_vpc.fitbyte_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "fitbyte_private"
  }
}

# === Create Subnet Group ===
resource "aws_db_subnet_group" "fitbyte_db" {
  name = "fitbyte-db"

  subnet_ids = [
    aws_subnet.fitbyte_private_a.id,
    aws_subnet.fitbyte_private_b.id,
  ]
}

# === Create IGW ===
resource "aws_internet_gateway" "fitbyte_igw" {
  vpc_id = aws_vpc.fitbyte_vpc.id

  tags = {
    Name = "fitbyte-igw"
  }
}

# Create Route Table for Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.fitbyte_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fitbyte_igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Associate public subnet with route table
resource "aws_route_table_association" "fitbyte_public_rt" {
  subnet_id      = aws_subnet.fitbyte_public_a.id
  route_table_id = aws_route_table.public.id
}