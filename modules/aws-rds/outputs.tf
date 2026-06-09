output "endpoint" {
  description = "RDS connection endpoint"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS port"
  value       = aws_db_instance.this.port
}

output "secret_arn" {
  description = "Secrets Manager ARN holding the master credentials"
  value       = aws_secretsmanager_secret.db.arn
}

output "security_group_id" {
  description = "Security group attached to the DB"
  value       = aws_security_group.this.id
}
