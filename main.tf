terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.4.0"
}

provider "aws" {
  region     = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

# 🧩 Security group allowing SSH + app port
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and port 5000"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask app port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🧱 EC2 instance using existing PEM key
resource "aws_instance" "python_app_ec2" {
  ami                    = "ami-0c50b6f7dc3701ddd" # Ubuntu 22.04 (ap-south-1)
  instance_type          = "t2.micro"
  key_name               = "Always.Pem"
  security_groups        = [aws_security_group.allow_ssh_http.name]
  associate_public_ip_address = true

  tags = {
    Name = "PythonAppServer"
  }
}

# 🖨 Output public IP
output "ec2_public_ip" {
  value = aws_instance.python_app_ec2.public_ip
}
