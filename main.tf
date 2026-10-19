data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source              = "./modules/vpc"
  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = slice(data.aws_availability_zones.available.names, 0, 2)
  single_nat_gateway  = var.single_nat_gateway
}

module "security_groups" {
  source           = "./modules/security_groups"
  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  app_port         = var.app_port
  allowed_ssh_cidr = var.allowed_ssh_cidr
  enable_bastion   = var.enable_bastion
  enable_https     = var.enable_https
}

module "alb" {
  source                 = "./modules/alb"
  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  alb_security_group_id  = module.security_groups.alb_security_group_id
  app_port               = var.app_port
  health_check_path      = var.alb_health_check_path
  enable_https           = var.enable_https
  acm_certificate_arn    = var.acm_certificate_arn
}

module "app" {
  source                  = "./modules/app"
  project_name            = var.project_name
  environment             = var.environment
  private_subnet_ids      = module.vpc.private_subnet_ids
  app_security_group_id   = module.security_groups.app_security_group_id
  target_group_arn        = module.alb.target_group_arn
  instance_type           = var.instance_type
  min_size                = var.asg_min_size
  desired_capacity        = var.asg_desired_capacity
  max_size                = var.asg_max_size
  app_port                = var.app_port
  cpu_target_value        = var.cpu_target_value
  rds_secret_arn          = module.rds.secret_arn
}

module "rds" {
  source                    = "./modules/rds"
  project_name              = var.project_name
  environment               = var.environment
  database_subnet_ids       = module.vpc.database_subnet_ids
  db_security_group_id      = module.security_groups.db_security_group_id
  db_instance_class         = var.db_instance_class
  db_name                   = var.db_name
  db_username               = var.db_username
  multi_az                  = var.db_multi_az
  deletion_protection       = var.db_deletion_protection
  skip_final_snapshot       = var.db_skip_final_snapshot
  backup_retention_period   = var.db_backup_retention_period
}

module "s3" {
  source         = "./modules/s3"
  project_name   = var.project_name
  environment    = var.environment
}

module "bastion" {
  count                  = var.enable_bastion ? 1 : 0
  source                 = "./modules/bastion"
  project_name           = var.project_name
  environment            = var.environment
  public_subnet_id       = module.vpc.public_subnet_ids[0]
  bastion_security_group_id = module.security_groups.bastion_security_group_id
  instance_type          = "t3.micro"
}

locals {
  environment_summary = {
    environment = var.environment
    region      = var.aws_region
    vpc_id      = module.vpc.vpc_id
    alb_dns     = module.alb.alb_dns_name
    rds_endpoint = module.rds.db_endpoint
    s3_bucket   = module.s3.bucket_name
  }
}
