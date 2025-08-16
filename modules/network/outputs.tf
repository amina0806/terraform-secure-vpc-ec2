output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets (ordered by for_each key)"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "IDs of private subnets (empty if none created)"
  value       = try([for s in aws_subnet.private : s.id], [])
}

output "nat_gateway_id" {
  description = "NAT Gateway ID (null if not created)"
  value       = try(aws_nat_gateway.this[0].id, null)
}
