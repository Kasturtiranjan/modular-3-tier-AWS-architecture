output "alb_dns_name" {
  description = "Public DNS of Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "rds_endpoint" {
  description = "Database connection endpoint"
  value       = module.rds.rds_endpoint
  sensitive   = true
}
