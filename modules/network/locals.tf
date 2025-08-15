locals {
  public_subnets = {
    for i, az in var.azs :
    az => { cidr = var.public_subnet_cidrs[i], az = az }
  }
}