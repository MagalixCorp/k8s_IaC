provider "aws" {
  region = var.region
}
module "vpc" {
  source = "./modules/VPC"
  VPC_name = var.VPC_name
  cidr_block = var.cidr_block
  region = var.region
}
module "public_rt" {
  source = "./modules/rt"
  public_rt_name = var.public_rt_name
  vpc_id = module.vpc.vpc_id
}
module "private_subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id
  cidr_block = var.private_subnet_cidr_block
  subnet_name = var.private_subnet_name
}

module "public_subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id
  cidr_block = var.public_subnet_cidr_block
  subnet_name = var.public_subnet_name
}

resource "aws_route_table_association" "a" {
  subnet_id      = module.public_subnet.subnet_id
  route_table_id = module.public_rt.route_table_id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = var.igw_name
  }
}
resource "aws_route" "public_route" {
  route_table_id            = module.public_rt.route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
  depends_on                = [module.public_rt,aws_internet_gateway.igw,aws_route_table_association.a]
}
resource "aws_eip" "e" {
  vpc      = true
}
resource "aws_nat_gateway" "gw" {
  allocation_id   = aws_eip.e.id
  subnet_id       = module.private_subnet.subnet_id
  depends_on      = [aws_eip.e,module.private_subnet]
  tags = {
    Name = var.ngw_name
  }
}
resource "aws_route" "private_route" {
  route_table_id            = module.vpc.default_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.gw.id
  depends_on                = [aws_nat_gateway.gw]
}