# ── Network baseline (VPC, public + private subnets, NAT) ──────────────────────
module "network" {
  source = "./modules/network"

  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # NAT for private egress (Step 2)
  create_nat         = true
  single_nat_gateway = true

  tags = var.tags
}

# ── Compute (Step 1 optional public EC2, Step 2 private EC2) ───────────────────
module "compute" {
  source = "./modules/compute"

  name_prefix = var.name_prefix
  vpc_id      = module.network.vpc_id
  tags        = var.tags

  # Step 1 (public EC2) OFF by default; turn on later if you want
  deploy_public_instance = false
  # If turning on, also pass: ami_id, subnet_id, my_ip_cidr, instance_name, etc.

  # Step 2 (private EC2) ON
  deploy_private_instance = true
  private_subnet_ids      = module.network.private_subnet_ids
  instance_type_private   = "t3.micro"
  egress_ports            = [80, 443]
}
