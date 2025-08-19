output "vpc_id" {
  value = aws_vpc.this.id
}
output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = values(aws_subnet.private)[*].id   
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = values(aws_subnet.public)[*].id   
}

output "private_route_table_ids" {
  description = "IDs of private route tables"
  value       = aws_route_table.private[*].id     
}

output "nat_gateway_id" {
  description = "NAT Gateway ID (null if not created)"
  value       = try(aws_nat_gateway.this[0].id, null)
}

# SG used by Interface VPC Endpoints
output "vpce_sg_id" {
  value       = aws_security_group.vpce.id
  description = "SG attached to SSM interface endpoints"
}

# Interface endpoint IDs (map keyed by service: ssm, ssmmessages, ec2messages)
output "ssm_interface_endpoint_ids" {
  value       = { for k, v in aws_vpc_endpoint.ssm_if : k => v.id }
  description = "Interface endpoint IDs for ssm/ssmmessages/ec2messages"
}

# S3 gateway endpoint
output "s3_gateway_endpoint_id" {
  value       = aws_vpc_endpoint.s3_gw.id
  description = "Gateway endpoint ID for S3"
}

# Logging resources
output "logs_bucket_name" {
  value       = aws_s3_bucket.logs.bucket
  description = "Central logs bucket name"
}

output "logs_kms_key_arn" {
  value       = aws_kms_key.logs.arn
  description = "KMS CMK ARN for logs bucket encryption"
}
