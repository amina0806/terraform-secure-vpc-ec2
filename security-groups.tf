
data "aws_security_group" "app_sg" {
  filter {
    name   = "group-name"
    values = ["terraform-secure-vpc-ec2-app-sg"]
  }

  vpc_id = "vpc-05ba2afc18c5691db"
}


# Rule so app_sg can talk to VPC endpoints (SSM, etc.)
#resource "aws_security_group_rule" "allow_app_to_vpce_https" {
  count                    = 0
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.network.vpce_sg_id
  source_security_group_id = var.priv_sg_id
  description              = "Allow SSM traffic from app_sg to VPC Interface Endpoints"
}

