variable "project_name" { type = string }
variable "environment" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "app_security_group_id" { type = string }
variable "target_group_arn" { type = string }
variable "instance_type" { type = string }
variable "min_size" { type = number }
variable "desired_capacity" { type = number }
variable "max_size" { type = number }
variable "app_port" { type = number }
variable "cpu_target_value" { type = number }

variable "rds_secret_arn" {
  type        = string
  description = "ARN of the RDS-managed master secret; only this secret is readable by app instances."
}
