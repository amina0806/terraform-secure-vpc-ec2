output "public_instance_id" {
  description = "Public EC2 instance ID (null if not created)"
  value       = try(aws_instance.public[0].id, null)
}

output "public_instance_public_ip" {
  description = "Public EC2 public IP (null if not created)"
  value       = try(aws_instance.public[0].public_ip, null)
}

output "private_instance_id" {
  description = "Private EC2 instance ID (null if not created)"
  value       = try(aws_instance.private[0].id, null)
}

output "private_instance_private_ip" {
  description = "Private EC2 private IP (null if not created)"
  value       = try(aws_instance.private[0].private_ip, null)
}

output "app_sg_id" {
  description = "Passthrough of the app SG ID provided to the module"
  value       = var.app_sg_id
}
