module "network" {
  source = "./modules/network"

  name_prefix = var.name_prefix
  tags        = var.tags

  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1c"]
  public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

  create_nat         = false
  single_nat_gateway = true
}

module "compute" {
  source = "./modules/compute"

  name_prefix             = var.name_prefix
  tags                    = var.tags
  vpc_id                  = module.network.vpc_id
  deploy_private_instance = true
  private_subnet_ids      = module.network.private_subnet_ids
  instance_type_private   = "t3.micro"
  app_sg_id               = data.aws_security_group.app_sg.id
}
