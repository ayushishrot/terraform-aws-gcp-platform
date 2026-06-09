output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN of the default target group"
  value       = aws_lb_target_group.this.arn
}

output "security_group_id" {
  description = "Security group attached to the ALB"
  value       = aws_security_group.alb.id
}
