output "application_url" {
  description = "Public URL of the Application Load Balancer"
  value       = "http://${aws_lb.public.dns_name}"
}

output "vpc_id" {
  description = "ID of the custom 3-tier VPC"
  value       = aws_vpc.main.id
}

output "rds_endpoint" {
  description = "Private DNS endpoint of the Amazon RDS MySQL database"
  value       = aws_db_instance.mysql.address
}

output "autoscaling_group_name" {
  description = "Name of the Application Tier Auto Scaling Group"
  value       = aws_autoscaling_group.php_app.name
}