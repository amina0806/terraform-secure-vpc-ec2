variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "terraform-secure-vpc-ec2"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "secure-vpc-ec2"
  }
}
variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1" 
}

variable "azs" {
  description = "AZs to use (index-aligned with subnet CIDRs)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}
