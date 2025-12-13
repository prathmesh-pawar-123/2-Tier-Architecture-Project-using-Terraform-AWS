# 2-Tier-Architecture-Project-using-Terraform-AWS

🏗️ 2-Tier Architecture Deployment on AWS using Terraform
This project demonstrates how to deploy a 2-Tier Architecture on AWS using Terraform.
The infrastructure includes:

VPC

Public & Private Subnets

EC2 Instances

GitHub Repository for IaC code

Fully automated provisioning using Terraform

📌 Project Flow (Based on Your Sequence)
GitHub Repository

Instances

VPC

Subnets

📁 1. GitHub Repository
Your Terraform code is stored in a GitHub repo for version control.

Repository Includes:
main.tf → VPC, Subnets, EC2 Instances

variable.tf

output.tf

main.tf

terraform.tfvars

![](./img/Screenshot%20(31).png)


🌐 2. VPC Creation
Terraform creates a custom VPC for the 2-tier architecture.

VPC Configuration:
CIDR Block (example): 10.0.0.0/16

DNS Hostnames Enabled

Tags for easy identification

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

![](./img/Screenshot%20(29).png)

🛰️ 3. Subnets (Public + Private)
Two subnets are created for a 2-tier setup:

Public Subnet
Hosts frontend server

Internet accessible

Private Subnet
Hosts backend server / DB

Not reachable from internet

Example:

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.private_cidr
  tags = {
    Name = "private-subnet"
  }
}

![](./img/Screenshot%20(28).png)

💻 4. EC2 Instances (Frontend + Backend)
Two instances are deployed:

Frontend Server (Public Subnet)
Accessible via Public IP

Web Server (Apache/Nginx)

Backend Server (Private Subnet)
No Public IP

Accessible only from Frontend Server

Example:

resource "aws_instance" "frontend" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "frontend-server"
  }
}

resource "aws_instance" "backend" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  tags = {
    Name = "backend-server"
  }
}

![](./img/Screenshot%20(30).png)

🚀 How to Deploy
1️⃣ Initialize Terraform
terraform init
2️⃣ Validate Configuration
terraform validate
3️⃣ Plan Deployment
terraform plan
4️⃣ Apply Infrastructure
terraform apply -auto-approve
📤 Outputs
Terraform displays:

VPC ID

Subnet IDs

Frontend Public IP

Backend Private IP

