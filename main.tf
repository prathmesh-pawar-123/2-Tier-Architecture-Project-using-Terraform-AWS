 terraform {
  backend "s3" {
    bucket = "terraform-backend-d55"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.private_cidr
  availability_zone       = var.az1      
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.public_cidr
  availability_zone       = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_IGW" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.project_name}-IGW"
  }
}

# Default Route Table
resource "aws_default_route_table" "main_RT" {
  default_route_table_id = aws_vpc.my-vpc.default_route_table_id

  tags = {
    Name = "${var.project_name}-main-RT"
  }
}

# Add a route in the main route table
resource "aws_route" "aws_route" {
  route_table_id         = aws_default_route_table.main_RT.id
  destination_cidr_block = var.igw_cidr
  gateway_id             = aws_internet_gateway.my_IGW.id
}

# Create Security Group
resource "aws_security_group" "my_sg" {
  vpc_id      = aws_vpc.my-vpc.id
  name        = "${var.project_name}-SG"
  description = "Allow SSH, HTTP, MySQL"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc.my-vpc]
}

# Public EC2 instance
resource "aws_instance" "public_server" {
  subnet_id              = aws_subnet.public_subnet.id
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "${var.project_name}-app-server"
  }

  depends_on = [aws_security_group.my_sg]
}

# Private EC2 instance
resource "aws_instance" "private_server" {
  subnet_id              = aws_subnet.private_subnet.id
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "${var.project_name}-db-server"
  }

  depends_on = [aws_security_group.my_sg]
}
