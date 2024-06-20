#This is for creating a VPC, Subnet, internet gateway, route table, Adding subnet to route table, Creating Securitygroup, launching EC2

provider "aws" {
  region = "us-east-1"
}
resource "aws_security_group" "test" {
    name="test"
    vpc_id = aws_vpc.test.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.test.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.test.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}
resource "aws_instance" "public_instance" {
  ami="ami-08a0d1e16fc3f61ea"
  subnet_id = aws_subnet.public.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "test"
  vpc_security_group_ids      = [aws_security_group.test.id]
}
resource "aws_instance" "private_instance" {
  ami="ami-08a0d1e16fc3f61ea"
  subnet_id = aws_subnet.private.id
  instance_type = "t2.micro"
  associate_public_ip_address = false
  key_name = "test"
}
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.test.id
}
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.test.id
}
resource "aws_route_table_association" "public-rt-association" {
    route_table_id = aws_route_table.public-rt.id
    subnet_id = aws_subnet.public.id
}
resource "aws_route_table_association" "private-rt-association" {
    route_table_id = aws_route_table.private-rt.id
    subnet_id = aws_subnet.private.id
}
resource "aws_internet_gateway" "igw" {   
  vpc_id = aws_vpc.test.id
}
resource "aws_eip" "forNAT" {
  domain = "vpc"
  }
resource "aws_nat_gateway" "NAT-test" {
  subnet_id     = aws_subnet.public.id
  allocation_id = aws_eip.forNAT.id
}
