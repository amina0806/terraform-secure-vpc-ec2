output "vpc_id" {
  value       = module.network.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.network.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.network.private_subnet_ids
  description = "Private subnet IDs"
}

output "nat_gateway_id" {
  value       = module.network.nat_gateway_id
  description = "NAT Gateway ID"
}

output "private_instance_id" {
  value       = module.compute.private_instance_id
  description = "Private EC2 instance ID"
}

output "private_instance_private_ip" {
  value       = module.compute.private_instance_private_ip
  description = "Private EC2 private IP"
}

