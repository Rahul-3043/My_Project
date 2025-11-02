provider "aws" {
  region = "ap-south-1"
}

variable "private_key" {
  description = "EC2 private key"
  type        = string
}

resource "null_resource" "run_python_app" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.private_key
    host        = "3.108.215.206"   # ✅ your EC2 public IP
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install docker.io -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",

      # Pull official Python Docker image
      "sudo docker pull python:3.9",

      # Run the app inside container
      "sudo mkdir -p /home/ubuntu/app",
      "cd /home/ubuntu/app",
      "echo 'print(\"Hello from Python in Docker!\")' > app.py",
      "echo 'flask' > requirements.txt",

      "sudo docker run -d -p 5000:5000 -v /home/ubuntu/app:/app python:3.9 bash -c 'pip install -r /app/requirements.txt && python /app/app.py'"
    ]
  }
}
