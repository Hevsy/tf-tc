variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access to the EC2 instance."
}

variable "ssh_location" {
  description = "The IP address range that can be used to SSH to the EC2 instances."
  type        = string
  default     = "0.0.0.0/0"
}

variable "image_id" {
  description = "EC2 Image ID - leave default for the latest Amazon Linux 2 image."
}

resource "aws_vpc" "finance_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  tags = {
    Name = "FinanceVPC"
  }
}

resource "aws_subnet" "private_subnet1" {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id            = aws_vpc.finance_vpc.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  availability_zone = data.aws_availability_zones.available.names[1]
  vpc_id            = aws_vpc.finance_vpc.id
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "PrivateSubnet2"
  }
}

resource "aws_subnet" "private_subnet3" {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id            = aws_vpc.finance_vpc.id
  cidr_block        = "10.0.3.0/24"
  tags = {
    Name = "PrivateSubnet3"
  }
}

resource "aws_subnet" "private_subnet4" {
  availability_zone = data.aws_availability_zones.available.names[1]
  vpc_id            = aws_vpc.finance_vpc.id
  cidr_block        = "10.0.4.0/24"
  tags = {
    Name = "PrivateSubnet4"
  }
}

resource "aws_subnet" "public_subnet1" {
  availability_zone   = data.aws_availability_zones.available.names[0]
  vpc_id              = aws_vpc.finance_vpc.id
  cidr_block          = "10.0.10.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  availability_zone   = data.aws_availability_zones.available.names[1]
  vpc_id              = aws_vpc.finance_vpc.id
  cidr_block          = "10.0.11.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet2"
  }
}

resource "aws_internet_gateway" "finance_igw" {
  vpc_id = aws_vpc.finance_vpc.id
  tags = {
    Name = "IGW-Finance"
  }
}

resource "aws_internet_gateway_attachment" "attach_gateway" {
  vpc_id             = aws_vpc.finance_vpc.id
  internet_gateway_id = aws_internet_gateway.finance_igw.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.finance_vpc.id
  tags = {
    Name = "FinRT-public"
  }
}

resource "aws_route" "public_rt_internet" {
route_table_id = aws_route_table.public_rt.id
destination_cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.finance_igw.id
}

resource "aws_route_table_association" "public_subnet1_association" {
subnet_id = aws_subnet.public_subnet1.id
route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet2_association" {
subnet_id = aws_subnet.public_subnet2.id
route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "finance_sg" {
name = "FinanceSecurityGroup"
description = "Security group for finance resources"

ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = [var.ssh_location]
}

ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

vpc_id = aws_vpc.finance_vpc.id
}
