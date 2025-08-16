variable "name_prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = []
}

variable "tags" {
  type = map(string)
}

variable "create_nat" {
  description = "Create a NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway in the first public subnet"
  type        = bool
  default     = true
}
