resource "aws_route_table" "rt" {
  vpc_id = var.vpc_id
  tags = {
    Name = var.public_rt_name
  }
}