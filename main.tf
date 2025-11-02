terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "DOCKER_USERNAME" {}
variable "DOCKER_PASSWORD" {}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "python_app" {
  ami           = "ami-0dee22c13ea7a9a67" # Amazon Linux 2 (Mumbai)
  instance_type = "t2.micro"
  key_name      = "Always"                # existing PEM key in AWS
  security_groups = [aws_security_group.allow_ssh_http.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              docker login -u ${var.DOCKER_USERNAME} -p ${var.DOCKER_PASSWORD}
              docker pull ${var.DOCKER_USERNAME}/python-app:latest
              docker run -d -p 80:80 ${var.DOCKER_USERNAME}/python-app:latest
              EOF

  tags = {
    Name = "12PM_Instance"
  }
}

output "public_ip" {
  value = aws_instance.python_app.public_ip
}
