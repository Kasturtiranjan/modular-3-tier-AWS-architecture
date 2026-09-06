# DB Subnet Group spanning private database subnets
resource "aws_db_subnet_group" "rds" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name        = "${var.environment}-rds-subnet-group"
    Environment = var.environment
  }
}

# Custom DB Parameter Group
resource "aws_db_parameter_group" "rds" {
  name_prefix = "${var.environment}-rds-params-"
  family      = var.engine == "postgres" ? "postgres15" : "mysql8.0"

  parameter {
    name  = var.engine == "postgres" ? "rds.force_ssl" : "require_secure_transport"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Amazon RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.environment}-db-instance"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [var.db_security_group_id]
  parameter_group_name   = aws_db_parameter_group.rds.name

  multi_az            = var.multi_az
  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name        = "${var.environment}-rds-instance"
    Environment = var.environment
  }
}
