# ========== Step 1: Public EC2 (optional) ==========

# Security group for public EC2 (create only if we have a subnet and want public)
resource "aws_security_group" "web" {
  count       = var.deploy_public_instance && var.subnet_id != null ? 1 : 0
  name        = "${var.name_prefix}-web-sg"
  description = "Allow SSH from my IP and HTTP from the world"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name_prefix}-web-sg" })
}

# SSH from my IP (only if provided)
resource "aws_vpc_security_group_ingress_rule" "ssh_my_ip" {
  count             = var.deploy_public_instance && var.subnet_id != null && var.my_ip_cidr != null ? 1 : 0
  security_group_id = aws_security_group.web[0].id
  cidr_ipv4         = var.my_ip_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "SSH from my IP"
}

# HTTP from anywhere
resource "aws_vpc_security_group_ingress_rule" "http_world" {
  count             = var.deploy_public_instance && var.subnet_id != null ? 1 : 0
  security_group_id = aws_security_group.web[0].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "HTTP from anywhere (demo)"
}

# Public EC2 (only if we have subnet_id and ami_id)
resource "aws_instance" "public" {
  count                       = var.deploy_public_instance && var.subnet_id != null && var.ami_id != null ? 1 : 0
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.web[0].id]
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device { encrypted = true }

  tags = merge(var.tags, { Name = "${var.name_prefix}-${var.instance_name}" })
}
