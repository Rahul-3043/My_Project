provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "ec2" {
  ami           = "ami-0e306788ff2473ccb"   # Ubuntu 22.04 (Mumbai)
  instance_type = "t2.micro"
  key_name      = "Rahul"                   # your .pem key name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo docker pull python:3.9
              sudo docker run -d -p 80:80 python:3.9
              EOF

  tags = {
    Name = "EC2_Git"
  }
}
