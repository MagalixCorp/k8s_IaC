variable "region" {
    description = "The AWS region where the components will get installed"
}
variable "VPC_name" {
    description = "The name tag of the VPC"
}
variable "cidr_block" {
    description = "The CIRD block to be used by the VPC"
}
variable "public_rt_name" {}
variable "public_subnet_cidr_block" {}
variable "private_subnet_cidr_block" {}
variable "private_subnet_name" {}
variable "public_subnet_name" {}
variable "igw_name" {}
variable "ngw_name" {}
variable "bastion_type" {}
variable "ami_id" {}
variable "k8s_ami_id" {}
variable "master_type" {}
variable "master_private_ip" {}