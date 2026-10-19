output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID."
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs."
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private app subnet IDs."
}

output "database_subnet_ids" {
  value       = module.vpc.database_subnet_ids
  description = "Database subnet IDs."
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "Public DNS name of the Application Load Balancer."
}

output "rds_endpoint" {
  value       = module.rds.db_endpoint
  description = "RDS endpoint (no password)."
}

output "rds_secret_arn" {
  value       = module.rds.secret_arn
  description = "Secrets Manager ARN; does not expose the password."
}

output "s3_bucket_name" {
  value       = module.s3.bucket_name
  description = "Private S3 bucket name."
}

output "target_group_arn" {
  value       = module.alb.target_group_arn
  description = "Target group ARN for health checks and troubleshooting."
}
