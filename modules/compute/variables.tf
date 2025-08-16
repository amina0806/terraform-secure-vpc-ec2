# ── Common ─────────────────────────────────────────────────────────────────────
variable "name_prefix" { type = string }
variable "vpc_id"      { type = string }
variable "tags"        { type = map(string) }

# ── Step 1 (Public EC2) —
variable "deploy_public_instance" {
  description = "Create the public EC2 (Step 1). If inputs are missing, resource is skipped."
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "Public EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI for public EC2 (optional; skip if null)"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Public subnet ID (optional; skip if null)"
  type        = string
  default     = null
}

variable "instance_name" {
  description = "Public EC2 Name tag"
  type        = string
  default     = "ec2-public"
}

variable "my_ip_cidr" {
  description = "Your IP CIDR for SSH to public EC2 (optional)"
  type        = string
  default     = null
}

# ── Step 2 (Private EC2) ───────────────────────────────────────────────────────
variable "deploy_private_instance" {
  description = "Create the private EC2 (Step 2)"
  type        = bool
  default     = false
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the private EC2"
  type        = list(string)
  default     = []
}

variable "instance_type_private" {
  description = "Private EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "egress_ports" {
  description = "Allowed egress TCP ports from private EC2"
  type        = list(number)
  default     = [80, 443]
}
