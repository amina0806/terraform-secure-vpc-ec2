variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "terraform-secure-vpc-ec2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}


variable "my_ip_cidr" {
  type    = string
  default = "211.177.229.27/32"
}

variable "tags" {
  type = map(string)
  default = {
    Project = "terraform-secure-vpc-ec2"
    Env     = "dev"
  }
}