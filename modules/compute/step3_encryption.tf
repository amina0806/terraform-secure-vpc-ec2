# ── Default EBS encryption (region-wide) ──
resource "aws_kms_key" "ebs" {
  description         = "CMK for default EBS encryption"
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "ebs" {
  name          = var.ebs_kms_alias
  target_key_id = aws_kms_key.ebs.key_id
}

resource "aws_ebs_encryption_by_default" "on" {
  count   = var.enable_ebs_encryption_default ? 1 : 0
  enabled = true
}

resource "aws_ebs_default_kms_key" "this" {
  count      = var.enable_ebs_encryption_default ? 1 : 0
  key_arn    = aws_kms_key.ebs.arn
  depends_on = [aws_ebs_encryption_by_default.on]
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon official
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]   # for x86_64
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "private_app" {
  count = var.deploy_private_instance ? 1 : 0

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type_private

  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.app_sg_id]

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-private-app" })
}
