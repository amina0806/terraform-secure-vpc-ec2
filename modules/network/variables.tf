variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "AZs used for subnets, index-aligned with cidr lists"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs, index-aligned with azs"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs, index-aligned with azs"
  type        = list(string)
}

variable "create_nat" {
  description = "Whether to create NAT resources"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Single NAT Gateway for all private subnets if true"
  type        = bool
  default     = true
}

variable "logs_bucket_name" {
  description = "Optional custom name for the logs bucket"
  type        = string
  default     = null
}
