terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.74.0"
      
    }
  }
  backend "s3" {
    region = "us-east-1"
    bucket = "megalapot2"
    key = "dev/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}




resource "aws_vpc" "main_vpc" {
  cidr_block = "10.10.15.0/26"
  enable_dns_hostnames = true
  tags = {
    Name = "Bash Vpc"
    Owner = var.owner
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "10.10.15.0/28"
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "allow_all_internet" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    gateway_id = aws_internet_gateway.gateway.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "allow_all_interne" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.allow_all_internet.id
}

resource "aws_security_group" "allow_http" {
  name_prefix = "http-"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    description = "http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Bash_Instance" {
  key_name = var.ssh_key_name
  subnet_id = aws_subnet.public_subnet.id
  instance_type = var.instance_type
  ami = "ami-005fc0f236362e99f"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_http.id]
}