# Specify the AWS provider and region
provider "aws" {
  region = var.region
}

# Create an EC2 instance
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "WebServer"
  }

  # User data script to install Apache and set up the web server
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Welcome to the Web Server</h1>" | sudo tee /var/www/html/index.html
              EOF

  # Associate the security group
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

# Create a security group to allow HTTP and HTTPS traffic
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and HTTPS traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

# Create a CloudWatch log group for monitoring
resource "aws_cloudwatch_log_group" "web_terraform_log_group" {
  name              = "web_terraform_log_group"
  retention_in_days = 14
}