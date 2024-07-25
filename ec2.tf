# Define the provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "web_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create subnets
resource "aws_subnet" "web_subnet_a" {
  vpc_id     = aws_vpc.web_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "web_subnet_b" {
  vpc_id     = aws_vpc.web_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Create an internet gateway
resource "aws_internet_gateway" "web_igw" {
  vpc_id = aws_vpc.web_vpc.id
}

# Create a route table
resource "aws_route_table" "web_route_table" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }
}

# Associate route table with subnets
resource "aws_route_table_association" "web_route_table_assoc_a" {
  subnet_id      = aws_subnet.web_subnet_a.id
  route_table_id = aws_route_table.web_route_table.id
}

resource "aws_route_table_association" "web_route_table_assoc_b" {
  subnet_id      = aws_subnet.web_subnet_b.id
  route_table_id = aws_route_table.web_route_table.id
}

# Create a security group
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.web_vpc.id

  ingress {
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

# Create an EC2 instance
resource "aws_instance" "web_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web_subnet_a.id
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > /var/www/html/index.html
              yum -y install httpd
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "WebServerInstance"
  }
}

# Create an ELB
resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.web_subnet_a.id, aws_subnet.web_subnet_b.id]

  enable_deletion_protection = false
}

# Create a target group
resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Register EC2 instance with the target group
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_instance.id
  port             = 80
}

# Create a listener for the ELB
resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Output the DNS name of the load balancer
output "web_lb_dns" {
  value = aws_lb.web_lb.dns_name
}