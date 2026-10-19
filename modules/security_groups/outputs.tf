output "alb_security_group_id" { value = aws_security_group.alb.id }
output "app_security_group_id" { value = aws_security_group.app.id }
output "db_security_group_id" { value = aws_security_group.db.id }
output "bastion_security_group_id" {
  value = var.enable_bastion ? aws_security_group.bastion[0].id : null
}
