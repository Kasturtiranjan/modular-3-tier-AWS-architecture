module "vpc" {
  source                   = "./modules/vpc"
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  availability_zones       = var.availability_zones
  environment              = var.environment
}

module "security" {
  source      = "./modules/security"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

module "alb" {
  source             = "./modules/alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  alb_sg_id          = module.security.alb_sg_id
  environment        = var.environment
}

module "ec2_asg" {
  source                 = "./modules/ec2_asg"
  vpc_id                 = module.vpc.vpc_id
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  app_sg_id              = module.security.app_sg_id
  target_group_arn       = module.alb.target_group_arn
  instance_type          = var.instance_type
  asg_min_size           = var.asg_min_size
  asg_max_size           = var.asg_max_size
  asg_desired_capacity   = var.asg_desired_capacity
  environment            = var.environment
}

module "rds" {
  source                = "./modules/rds"
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  db_sg_id              = module.security.db_sg_id
  allocated_storage     = var.db_allocated_storage
  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  environment           = var.environment
}
