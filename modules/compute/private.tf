data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter { 
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter { 
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter { 
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_security_group" "priv" {
  count       = var.deploy_private_instance ? 1 : 0
  name        = "${var.name_prefix}-priv-sg"
  description = "Egress-only for private EC2"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name_prefix}-priv-sg" })
}

resource "aws_vpc_security_group_egress_rule" "priv_out" {
  for_each          = var.deploy_private_instance ? { for p in var.egress_ports : tostring(p) => p } : {}
  security_group_id = aws_security_group.priv[0].id
  ip_protocol       = "tcp"
  from_port         = each.value
  to_port           = each.value
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow egress TCP ${each.value}"
}

resource "aws_iam_role" "ssm" {
  count = var.deploy_private_instance ? 1 : 0
  name  = "${var.name_prefix}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  count      = var.deploy_private_instance ? 1 : 0
  role       = aws_iam_role.ssm[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  count = var.deploy_private_instance ? 1 : 0
  name  = "${var.name_prefix}-ssm-profile"
  role  = aws_iam_role.ssm[0].name
}

resource "aws_instance" "private" {
  count                = var.deploy_private_instance ? 1 : 0
  ami                  = data.aws_ami.al2023.id
  instance_type        = var.instance_type_private
  subnet_id            = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.priv[0].id]
  iam_instance_profile = aws_iam_instance_profile.ssm[0].name
  associate_public_ip_address = false


  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" 
  }

  root_block_device {
    encrypted = true 
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-ec2-private" })
}