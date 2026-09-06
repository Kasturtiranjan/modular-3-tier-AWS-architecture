variable "environment" {
  description = "Deployment environment name (e.g., prod, staging, dev)"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "List of private subnet IDs where RDS should be deployed"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID allowing inbound access from the app tier"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum limit for storage autoscaling in gigabytes"
  type        = number
  default     = 100
}

variable "engine" {
  description = "Database engine type (postgres or mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the default database to create"
  type        = string
}

variable "db_username" {
  description = "Master username for database access"
  type        = string
}

variable "db_password" {
  description = "Master database password"
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "Specifies if the RDS instance is Multi-AZ"
  type        = bool
  default     = false
}
