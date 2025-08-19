data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  endpoint_services = toset(["ssm", "ssmmessages", "ec2messages"])

  logs_bucket_name = coalesce(
    var.logs_bucket_name,
    lower("${var.name_prefix}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-logs")
  )
  private_subnet_ids = values(aws_subnet.private)[*].id
  private_rtb_ids    = aws_route_table.private[*].id
}

# SG for Interface Endpoints
resource "aws_security_group" "vpce" {
  name        = "${var.name_prefix}-vpce-sg"
  description = "Allows HTTPS from app_sg to Interface Endpoints"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpce-sg" })
}

# Interface Endpoints (SSM trio)
resource "aws_vpc_endpoint" "ssm_if" {
  for_each            = local.endpoint_services
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = local.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce.id]
  tags                = merge(var.tags, { Name = "${var.name_prefix}-vpce-${each.key}" })
}

# S3 Gateway Endpoint (attach to PRIVATE route tables)
resource "aws_vpc_endpoint" "s3_gw" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = local.private_rtb_ids
  tags              = merge(var.tags, { Name = "${var.name_prefix}-vpce-s3" })
}

# KMS for logs (as you had)
resource "aws_kms_key" "logs" {
  description         = "CMK for central logs (VPC Flow Logs to S3)"
  enable_key_rotation = true
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowAccountAdministration",
        Effect   = "Allow",
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
        Action   = ["kms:*"],
        Resource = "*"
      },
      {
        Sid      = "AllowVPCFlowLogsServiceUse",
        Effect   = "Allow",
        Principal = { Service = "delivery.logs.amazonaws.com" },
        Action   = ["kms:Encrypt","kms:GenerateDataKey*","kms:DescribeKey"],
        Resource = "*",
        Condition = {
          StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${var.name_prefix}-logs"
  target_key_id = aws_kms_key.logs.key_id
}

# Logs bucket (BPA, versioning, SSE-KMS)
resource "aws_s3_bucket" "logs" {
  bucket        = local.logs_bucket_name
  force_destroy = false
  tags          = merge(var.tags, { Name = local.logs_bucket_name })
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.logs.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Bucket policy for VPC Flow Logs delivery

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowVPCFlowLogsPutObject",
        Effect    = "Allow",
        Principal = { Service = "delivery.logs.amazonaws.com" },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.logs.arn}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"      = "bucket-owner-full-control",
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid       = "AllowVPCFlowLogsGetBucketAcl",
        Effect    = "Allow",
        Principal = { Service = "delivery.logs.amazonaws.com" },
        Action    = "s3:GetBucketAcl",
        Resource  = aws_s3_bucket.logs.arn,
        Condition = {
          StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id }
        }
      }
    ]
  })
}

# VPC Flow Logs → S3
resource "aws_flow_log" "vpc_all" {
  vpc_id                   = aws_vpc.this.id
  traffic_type             = "ALL"
  log_destination_type     = "s3"
  log_destination          = aws_s3_bucket.logs.arn
  max_aggregation_interval = 60
  tags                     = merge(var.tags, { Name = "${var.name_prefix}-vpc-flow-logs" })
}
