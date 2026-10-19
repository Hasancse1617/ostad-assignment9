resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnets"
  subnet_ids = var.database_subnet_ids
  tags       = { Name = "${var.project_name}-${var.environment}-db-subnets" }
}

resource "aws_db_instance" "this" {
  identifier                  = "${var.project_name}-${var.environment}-mysql"
  engine                      = "mysql"
  instance_class              = var.db_instance_class
  allocated_storage           = 20
  max_allocated_storage       = 100
  storage_type                = "gp3"
  storage_encrypted           = true
  db_name                     = var.db_name
  username                    = var.db_username
  manage_master_user_password = true
  port                        = 3306
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [var.db_security_group_id]
  publicly_accessible         = false
  multi_az                    = var.multi_az
  deletion_protection         = var.deletion_protection
  backup_retention_period     = var.backup_retention_period
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-final-snapshot"
  auto_minor_version_upgrade  = true
  apply_immediately           = false
  copy_tags_to_snapshot       = true
  tags = { Name = "${var.project_name}-${var.environment}-mysql" }
  lifecycle {
    prevent_destroy = false
  }
}
