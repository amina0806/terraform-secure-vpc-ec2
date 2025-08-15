data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "network" {
  source              = "./modules/network"
  name_prefix         = var.project_name
  vpc_cidr            = var.vpc_cidr
  azs                 = var.azs
  public_subnet_cidrs = var.public_subnet_cidrs
  tags                = var.tags
}

module "compute" {
  source        = "./modules/compute"
  name_prefix   = var.project_name
  vpc_id        = module.network.vpc_id
  subnet_id     = module.network.public_subnet_ids[0]
  instance_type = var.instance_type
  instance_name = "web"
  ami_id        = data.aws_ami.amazon_linux2.id
  my_ip_cidr    = var.my_ip_cidr
  tags          = var.tags
}
