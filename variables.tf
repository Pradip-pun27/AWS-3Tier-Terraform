variable "aws_region" {
  description = "AWS region where the 3-tier infrastructure will be deployed"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix used for naming AWS resources"
  type        = string
  default     = "php-3tier"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type for the PHP Application Tier"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum number of PHP EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "Desired number of PHP EC2 instances across 2 Availability Zones"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of PHP EC2 instances during traffic spikes"
  type        = number
  default     = 3
}

variable "db_instance_class" {
  description = "RDS MySQL instance size (Free Tier eligible)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Initial MySQL database name"
  type        = string
  default     = "student_portal"
}

variable "db_username" {
  description = "Master username for RDS MySQL"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for RDS MySQL (min 8 chars, no /, @, \", or spaces)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "The database password must be at least 8 characters long."
  }
}