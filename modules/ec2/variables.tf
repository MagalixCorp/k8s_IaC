variable "ami_id" {}
variable "instance_type" {}
variable "ec2_name" {}
variable "az" {}
variable "key_name" {}
variable "security_groups" {
    type = list
}
variable "associate_public_ip_address" {}
variable "subnet_id" {}