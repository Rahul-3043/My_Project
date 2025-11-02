provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "web_app" {
  ami           = "ami-0e306788ff2473ccb"  # Ubuntu 22.04
  instance_type = "t2.micro"
  key_name      = "Rahul"                  # your key pair name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install docker.io -y
              sudo systemctl start docker
              sudo docker run -d -p 5000:5000 rahulgitte/myapp:latest
              EOF

  tags = {
    Name = "Terraform-CICD-App"
  }
}

output "public_ip" {
  value = aws_instance.web_app.public_ip
}
