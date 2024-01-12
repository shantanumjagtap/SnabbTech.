# Specify the AWS provider with the desired region.
provider "aws" {
  region = "ap-south-1"
}

# Create a VPC.
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create two subnets in different availability zones.
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
}

# Create a route table.
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create an Internet Gateway and associate it with the VPC.
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a security group (if needed).
resource "aws_security_group" "my_sg" {
  name        = "my-security-group"
  description = "Allow HTTP inbound"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance in one of the subnets.
resource "aws_instance" "my_instance" {
  ami           = "ami-0c42696027a8ede58"  # Your desired AMI ID
  instance_type = "t2.micro"
  key_name      = "develop"  # Replace with your key pair name
  subnet_id     = aws_subnet.subnet1.id  # Use one of the subnets you created
  
  tags = {
    "Name" = "Developement"
  }
}

# Create a route to the Internet through the Internet Gateway.
resource "aws_route" "my_route" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}
