variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 LTS
}

variable "instance_type" {
  description = "The instance type to use for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair to use"
  type        = string
  default     = "my-key-pair"
}

variable "key_path" {
  description = "Path to the SSH private key"
  default     = "~/.ssh/my-key.pem"
}

variable "ngrok_authtoken" {
  description = "Your ngrok authtoken"
}