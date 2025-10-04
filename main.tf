terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

# Security group for SonarQube

# resource "aws_subnet" "main" {
#   vpc_id     = var.vpc_id
#   cidr_block = "10.0.0.0/20"

#   tags = {
#     Name = "Main"
#   }
# }


resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube_security_group"
  description = "Allow SonarQube and SSH Traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SonarQube access"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SonarQube Security Group"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    #al2023-ami-2023.8.20250908.0-kernel-6.1-x86_64
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]   #forces subnets from the same VPC
  }
}

resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.large"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]
  subnet_id              = data.aws_subnets.all.ids[0]  # or an existing subnet ID
  user_data              = file("install_sonarqube.sh")

  tags = {
    Name = "SonarQube Instance"
  }
}

# resource "aws_instance" "sonarqube" {
#   ami             = data.aws_ami.amazon_linux.id
#   instance_type   = "t2.large"
#   key_name        = var.key_name
#   security_groups = [aws_security_group.sonarqube_sg.name]
#   # subnet_id       = aws_subnet.main.id
#   user_data       = file("install_sonarqube.sh")

#   tags = {
#     Name = "SonarQube Instance"
#   }
# }
