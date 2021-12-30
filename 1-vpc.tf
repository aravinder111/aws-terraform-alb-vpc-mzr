# create a vpc with following cidr
resource "aws_vpc" "demovpc" {
  cidr_block       = "172.1.0.0/25"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "demovpc"
  }
}

# create an internet gateway to give our vpc subnets access to internet
resource "aws_internet_gateway" "demovpc-igw" {
  vpc_id = aws_vpc.demovpc.id

  tags = {
    Name = "demovpc-igw"
  }
}

# Grant the VPC internet access on its main route table.
resource "aws_route" "demovpc-igw-route" {
  route_table_id            = aws_vpc.demovpc.main_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.demovpc-igw.id
}

# create two subnets as asked
resource "aws_subnet" "demovpc-public-subnet-1" {
  vpc_id                  = aws_vpc.demovpc.id
  cidr_block              = "172.1.0.0/26"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "demovpc-public-subnet-1"
  }
}
resource "aws_subnet" "demovpc-public-subnet-2" {
  vpc_id                  = aws_vpc.demovpc.id
  cidr_block              = "172.1.0.64/26"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "demovpc-public-subnet-2"
  }
}
