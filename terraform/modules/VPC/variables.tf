variable "region" {
    description = "The AWS region where the components will get installed"
}
variable "VPC_name" {
    description = "The name tag of the VPC"
}
variable "cidr_block" {
    description = "The CIDR block that the VPC would use"
}