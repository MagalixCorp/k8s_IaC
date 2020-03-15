resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "The bastion server security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from the world"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion"
  }
}

resource "aws_security_group" "k8s" {
  name        = "k8s"
  description = "The cluster security. Traffic is allowed among nodes with this SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "All traffic from the same subnet block"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.private_subnet_cidr_block]
  }
  ingress {
    description = "All SSH traffic only from the bastion server"
    from_port           = 22
    to_port             = 22
    protocol            = "TCP"
    security_groups  = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tags"
  }
}