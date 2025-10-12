output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "IDs of all public subnets"
  value       = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]
}

output "private_subnet_id" {
  description = "IDs of all private subnets"
  value       = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]
}
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
output "bastion_public_dns" { 
  value = aws_instance.bastion.public_dns 
}
output "dynamodb_table_name" { 
 value = aws_dynamodb_table.book_inventory.name
}

