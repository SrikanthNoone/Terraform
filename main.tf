#This is for creating a VPC, Subnet, internet gateway, route table, Adding subnet to route table, Creating Securitygroup, launching EC2

provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

# Create Subnet within the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a" 

  tags = {
    Name = "my-subnet"
  }
}
# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

# Associate Subnet with Route Table
resource "aws_route_table_association" "my_subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}


# Create Security Group for SSH access
resource "aws_security_group" "ssh_sg" {
  name        = "ssh-security-group"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }
}

# Launch an EC2 instance in the subnet
resource "aws_instance" "my_instance" {
  ami           = "ami-08a0d1e16fc3f61ea"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  key_name      = "test"  # Replace with your SSH key pair name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]

  tags = {
    Name = "my-instance"
  }
}

output "my_instance" {
  value = aws_instance.my_instance.public_ip
}
