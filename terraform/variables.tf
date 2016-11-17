variable "aws_region" {
  description = "The AWS region to create things in."
}

variable "aws_amis" {
  type = "map"
  default = {
    "us-east-1" = ""
    "us-west-2" = ""
  }
}

variable "server_ips" {
  type = "map"
  default = {
    "0" = ""
  }
}

variable "vpc_cidr_block" {
  description = "VPC IP Range"
}

variable "availability_zones" {
  description = "List of availability zones, use AWS CLI to find yours "
}

variable "key_name" {
  description = "Name of AWS key pair"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
}

variable "server_instance_type" {
  description = "server instance type"
}

variable "client_instance_type" {
  description = "client instance type"
}

variable "privateDNS" {
  description = "private dns name for serverhost"
}

variable "my_ip" {
  description = "my static ip"
}

variable "version" {
  type    = "map"
  default = {
    nomad = "0.5.0"
    consul = "0.7.1"
    vault = "0.6.2"
    hashistack = "0.2.0"
  }
}
