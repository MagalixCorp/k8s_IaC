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
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7kyzmKjjV+J7OTULE7G1JcJOaF4iwNqWhCEXl7h7600w6jtNPi1COJdM4dZX+Hdxkr92mqGgbjX4N3ZXFvN51MpGIca+f9Bvz6D6ggnJWRl5j/8L+iBhSUnUrL8EP8iXWMyhopff2INzykNJkECjUg6ChbwGs2DapwtviCp0IHIFpenw7uvpCfyXcgl7bVWUao35Zc2zc5n7TQ3fXFN254dOfANU3ukR2824IKkjO1rEbLdPw/7k/3l2C3FsbuK0bw43ffm1QRfAcSUstxNOkeWqbAQqEGxL0m136IfeoQcHLlH8hQLb0aQaKvijKpCmEpc8eEUh5lVYNF96Gkst7 ahmad@Ahmads-MacBook-Pro.local"
}

module "bastion_instance" {
  source                      = "./modules/ec2"
  ec2_name                    = "bastion"
  ami_id                      = var.ami_id
  instance_type               = var.bastion_type
  az                          = module.public_subnet.az
  subnet_id                   = module.public_subnet.subnet_id
  key_name                    = "deployer-key"
  security_groups             = [aws_security_group.bastion.id]
  associate_public_ip_address = true
}
module "k8s_master_instance" {
  source                      = "./modules/ec2"
  ec2_name                    = "master"
  ami_id                      = var.k8s_ami_id
  instance_type               = var.node_type
  az                          = module.private_subnet.az
  subnet_id                   = module.private_subnet.subnet_id
  key_name                    = "deployer-key"
  security_groups             = [aws_security_group.k8s.id]
  associate_public_ip_address = false
}
module "k8s_worker_instance" {
  source                      = "./modules/ec2"
  ec2_name                    = "worker"
  ami_id                      = var.k8s_ami_id
  instance_type               = var.node_type
  az                          = module.private_subnet.az
  subnet_id                   = module.private_subnet.subnet_id
  key_name                    = "deployer-key"
  security_groups             = [aws_security_group.k8s.id]
  associate_public_ip_address = false
}