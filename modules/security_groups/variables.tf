variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "app_port" { type = number }
variable "allowed_ssh_cidr" { type = string }
variable "enable_bastion" { type = bool }
