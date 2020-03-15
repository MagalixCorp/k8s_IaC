resource "aws_instance" "ec2" {
  ami                           = var.ami_id
  instance_type                 = var.instance_type
  availability_zone             = var.az
  subnet_id                     = var.subnet_id
  key_name                      = var.key_name
  vpc_security_group_ids        = var.security_groups
  associate_public_ip_address   = var.associate_public_ip_address

  tags = {
    Name = var.ec2_name
  }
}