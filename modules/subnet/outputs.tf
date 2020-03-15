output "subnet_id" {
  value = aws_subnet.subnet.id
}
output "az" {
  value = aws_subnet.subnet.availability_zone
}