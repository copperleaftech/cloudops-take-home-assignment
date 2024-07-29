# Define the AWS region variable
variable "region" {
  description = "The AWS region to deploy to"
  default = "us-west-2"
}

# Define the AMI ID variable
variable "ami_id" {
  description = "The ID of the AMI to use for the instance"
  default = "ami-0648742c7600c103f"  # Update with your preferred AMI
}

# Define the instance type variable
variable "instance_type" {
  description = "The instance type to use"
  default = "t2.micro"
}

# Define the key pair name variable
variable "key_name" {
  description = "The name of the key pair to use"
  default = "my_key_pair"
}

# Define the public key path variable
variable "public_key_path" {
  description = "The path to the SSH public key"
  default = "~/.ssh/id_rsa.pub"
}
