# main.tf

# Define the AWS provider (region can be defined in a variable)
provider "aws" {
  region = var.region  # Define your region in the variable `region`
}

# Terraform backend configuration happens before resources are created, so it cannot reference the S3 bucket until it exists.
# Configure the backend to use S3 and DynamoDB for state management
terraform {
  backend "s3" {
    bucket         = "divyankm-gitops-my-unique-terraform-state-bucket"  # Reference the created S3 bucket for state storage
    key            = "terraform.tfstate"  # Define the path inside the bucket to store the state file
    region         = "ap-south-1"  # Use the variable for region
    encrypt        = true  # Encrypt the state file in S3 for security
    dynamodb_table = "terraform-locks"  # Reference the DynamoDB table for state locking
    acl            = "private"  # Make the state file private
  }
}

# Define the VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"  # Define the CIDR block for the VPC
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

# Create a public subnet within the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"  # Define subnet CIDR block
  availability_zone       = "ap-south-1a"  # Reference region variable for Availability Zone
  map_public_ip_on_launch = true  # Assign public IPs to instances
  tags = {
    Name = "PublicSubnet"
  }
}

# Create an Internet Gateway to allow internet access
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

# Create a route table for the public subnet to route traffic to the internet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  # Route all traffic to the internet
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate the public subnet with the route table
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Provision the EC2 instance using the generated SSH Key Pair
resource "aws_instance" "gitops_server" {
  ami           = var.ami_id  # Ensure this is a valid Ubuntu AMI
  instance_type = var.instance_type  # Example: "t2.micro"
  key_name      = "gitops_key"        # Reference the existing key pair name in AWS

  vpc_security_group_ids = [aws_security_group.gitops_sg.id]
  subnet_id             = aws_subnet.public_subnet.id  # Launch EC2 in the public subnet

  root_block_device {
    volume_size = 20  # Size in GB
    volume_type = "gp2"  # General Purpose SSD (default)
    delete_on_termination = true  # Automatically delete the volume when the EC2 instance is terminated
  }

  tags = {
    Name = "DevOps-Test-Server"
  }
}

# Security Group to allow SSH access
resource "aws_security_group" "gitops_sg" {
  name_prefix = "gitops-sg-"
  description = "Allow SSH access to the GitOps server"
  vpc_id      = aws_vpc.my_vpc.id  # Ensure the security group is in the same VPC as the subnet

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs for testing, adjust as needed
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs for HTTP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs for HTTPS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*
# Create an additional EBS volume in case EBS Needs to be seperate from EC2
resource "aws_ebs_volume" "additional_volume" {
  availability_zone = aws_instance.gitops_server.availability_zone  # Reference the instance's AZ
  size              = 20  # Size in GB
  volume_type       = "gp2"  # General Purpose SSD

  tags = {
    Name = "AdditionalVolume"
  }
}

# Attach the additional EBS volume to the EC2 instance
resource "aws_volume_attachment" "attach_additional_volume" {
  device_name = "/dev/sdf"  # The device name (example: /dev/sdf)
  volume_id   = aws_ebs_volume.additional_volume.id  # Reference the volume created
  instance_id = aws_instance.gitops_server.id  # Attach to the EC2 instance
}
*/
