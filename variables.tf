variable "project_name" {
  description = "Project tag/name."
  type        = string
  default     = "novacart"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "ap-southeast-1"
}

variable "owner" {
  description = "Owner tag value."
  type        = string
  default     = "Hasan"
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR."
  type        = string
  default     = "10.20.0.0/16"
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use one NAT for low-cost dev; false creates one NAT per AZ."
}

variable "enable_bastion" {
  type        = bool
  description = "Create an optional bastion host. Prefer SSM for normal access."
  default     = false
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "Your public IPv4 /32 for optional bastion SSH."
  default     = "127.0.0.1/32"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the app fleet."
}

variable "asg_min_size" {
  type        = number
  description = "Minimum ASG size."
}

variable "asg_desired_capacity" {
  type        = number
  description = "Desired ASG capacity."
}

variable "asg_max_size" {
  type        = number
  description = "Maximum ASG size."
}

variable "db_multi_az" {
  type        = bool
  description = "Enable RDS Multi-AZ."
}

variable "db_deletion_protection" {
  type        = bool
  description = "Enable RDS deletion protection."
}

variable "db_skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot (dev only)."
}

variable "db_backup_retention_period" {
  type        = number
  description = "RDS automated backup retention days."
  default     = 7
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class."
  default     = "db.t3.micro"
}

variable "db_name" {
  type        = string
  description = "Initial database name."
  default     = "novacart"
}

variable "db_username" {
  type        = string
  description = "RDS master username (not password)."
  default     = "novacart_admin"
}

variable "app_port" {
  type        = number
  description = "Port served by nginx in app instances."
  default     = 80
}

variable "alb_health_check_path" {
  type        = string
  description = "ALB target group health-check path."
  default     = "/"
}

variable "cpu_target_value" {
  type        = number
  description = "Target average ASG CPU utilization percentage."
  default     = 50
}

variable "enable_https" {
  type        = bool
  description = "Enable HTTPS listener (requires ACM certificate ARN)."
  default     = false
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS."
  default     = ""
}
