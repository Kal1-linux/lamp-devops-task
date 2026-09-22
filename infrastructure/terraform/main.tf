terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------
# Networking: minimal VPC with one public subnet, an IGW, and a route table
# ---------------------------------------------------------------------------
resource "aws_vpc" "lamp_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "lamp-vpc" }
}

resource "aws_internet_gateway" "lamp_igw" {
  vpc_id = aws_vpc.lamp_vpc.id
  tags   = { Name = "lamp-igw" }
}

resource "aws_subnet" "lamp_public_subnet" {
  vpc_id                  = aws_vpc.lamp_vpc.id
  cidr_block               = var.public_subnet_cidr
  map_public_ip_on_launch  = true
  availability_zone        = data.aws_availability_zones.available.names[0]
  tags = { Name = "lamp-public-subnet" }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_route_table" "lamp_public_rt" {
  vpc_id = aws_vpc.lamp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lamp_igw.id
  }

  tags = { Name = "lamp-public-rt" }
}

resource "aws_route_table_association" "lamp_public_rta" {
  subnet_id      = aws_subnet.lamp_public_subnet.id
  route_table_id = aws_route_table.lamp_public_rt.id
}

# ---------------------------------------------------------------------------
# Security Group: HTTP/HTTPS from anywhere, SSH from a restricted CIDR
# ---------------------------------------------------------------------------
resource "aws_security_group" "lamp_sg" {
  name        = "lamp-web-sg"
  description = "Allow HTTP/HTTPS inbound, SSH from a restricted CIDR"
  vpc_id      = aws_vpc.lamp_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "lamp-web-sg" }
}

# ---------------------------------------------------------------------------
# IAM role for the instance (SSM access so we can manage it without opening
# extra ports, e.g. for future automation/patching)
# ---------------------------------------------------------------------------
resource "aws_iam_role" "lamp_ec2_role" {
  name = "lamp-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.lamp_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "lamp_instance_profile" {
  name = "lamp-instance-profile"
  role = aws_iam_role.lamp_ec2_role.name
}

# ---------------------------------------------------------------------------
# EC2 instance
# ---------------------------------------------------------------------------
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "lamp_web" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.lamp_public_subnet.id
  vpc_security_group_ids = [aws_security_group.lamp_sg.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.lamp_instance_profile.name

  tags = { Name = "lamp-web-server" }
}
