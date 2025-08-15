variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "instance_type" { type = string }
variable "instance_name" { type = string }
variable "my_ip_cidr" { type = string }
variable "tags" { type = map(string) }
variable "ami_id" { type = string }
