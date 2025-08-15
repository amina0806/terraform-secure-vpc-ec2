output "vpc_id" { value = module.network.vpc_id }
output "public_subnet_ids" { value = module.network.public_subnet_ids }
output "instance_public_ip" { value = module.compute.public_ip }
output "instance_id" { value = module.compute.instance_id }