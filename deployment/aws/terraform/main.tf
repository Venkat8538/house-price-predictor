terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for latest Ubuntu AMI
data "aws_ami" "ubuntu" {
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

# Security Group for Airflow
resource "aws_security_group" "airflow_sg" {
  name_prefix = "airflow-mlops-"
  description = "Security group for Airflow MLOps server"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Airflow UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MLflow UI"
    from_port   = 5555
    to_port     = 5555
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "FastAPI"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Streamlit"
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "airflow-mlops-sg"
  }
}

# Key Pair
resource "aws_key_pair" "airflow_key" {
  key_name   = "airflow-mlops-key"
  public_key = file(var.public_key_path)
}

# EC2 Instance
resource "aws_instance" "airflow_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.airflow_key.key_name
  vpc_security_group_ids = [aws_security_group.airflow_sg.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    github_repo = var.github_repo
  }))

  tags = {
    Name = "airflow-mlops-server"
    Type = "MLOps"
  }
}

# Elastic IP
resource "aws_eip" "airflow_eip" {
  instance = aws_instance.airflow_server.id
  domain   = "vpc"

  tags = {
    Name = "airflow-mlops-eip"
  }
}