/*..This Terraform configuration sets up a basic AWS infrastructure with VPC, subnets, NAT gateway, and EC2 instances.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = ">= 0.12"
}..*/
# This Terraform configuration sets up a AWS infrastructure VPC
module "vpc" {
  source    = "./modules/network/vpc"
  vpc_cidr  = "10.0.0.0/16"
  vpc_name  = "GenAI-VPC"
}
# This Terraform configuration sets up a AWS Internet Gateway
module "igw" {
  source = "./modules/network/ig"
  vpc_id = module.vpc.vpc_id
}
# This Terraform configuration sets up a AWS infrastructure subnets
module "subnets" {
  source                = "./modules/network/subnets"
  vpc_id                = module.vpc.vpc_id
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  azs                   = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
# This Terraform configuration sets up a AWS infrastructure security groups
module "sg" {
  source = "./modules/network/security-groups"
  vpc_id = module.vpc.vpc_id
}
# This Terraform configuration sets up a AWS infrastructure NAT Gateway
module "nat" {
  source             = "./modules/network/nat"
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.vpc.igw_id
  public_subnet_ids  = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
}
# This Terraform configuration sets up a AWS infrastructure EC2 instances
module "ecs" {
  source             = "./modules/compute/ecs"
  cluster_name       = "my-ecs-cluster"
  container_image    = "nginx:latest"
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn  # Create this in IAM
  private_subnet_ids = module.subnets.private_subnet_ids
  security_group_id  = module.sg.ec2_sg_id
}
# This Terraform configuration sets up a AWS infrastructure EKS cluster
module "eks" {
  source             = "./modules/compute/eks"
  cluster_name       = "eks-private-cluster"
  cluster_role_arn   = aws_iam_role.eksClusterRole.arn
  node_role_arn      = aws_iam_role.eksNodeGroupRole.arn
  private_subnet_ids = module.subnets.private_subnet_ids
}

# This Terraform configuration sets up a AWS Aurora database

module "aurora" {
  source             = "./modules/database/aurora"
  vpc_id             = module.vpc.vpc_id
  db_subnet_ids      = module.subnets.private_subnet_ids
  security_group_ids = [module.security_groups.rds_sg_id]
  db_name            = "auroradb"
}

# This Terraform configuration sets up a AWS RDS MySQL database

module "mysql_rds" {
  source             = "./modules/database/rds-mysql"
  vpc_id             = module.vpc.vpc_id
  db_subnet_ids      = module.subnets.private_subnet_ids
  security_group_ids = [module.security_groups.rds_sg_id]
  db_name            = "mysqldb"
}
module "bedrock" {
  source = "./modules/genai/bedrock"
  region = var.aws_region
}

module "comprehend" {
  source = "./modules/genai/comprehend"
  region = var.aws_region
}
module "cloudtrail" {
  source = "./modules/monitoring/cloudtrail"
}

module "cloudwatch" {
  source = "./modules/monitoring/cloudwatch"
}

module "sns" {
  source        = "./modules/monitoring/sns"
  alert_email   = var.alert_email
  aws_account_id = var.aws_account_id
}
module "waf" {
  source              = "./modules/security/waf"
  alb_arn             = module.alb.alb_arn
  web_acl_name        = "alb-web-acl"
  web_acl_description = "Protect ALB from bad bots"
}
module "iam" {
  source = "./modules/security/iam"
}

module "kms" {
  source = "./modules/security/kms"
}

module "guardduty" {
  source = "./modules/security/guardduty"
}

module "inspector" {
  source = "./modules/security/inspector"
}

module "shield" {
  source = "./modules/security/shield"
}
module "logs_bucket" {
  source      = "./modules/s3_logs_bucket"
  bucket_name = "aeonx-central-logs-${var.environment}"
  tags        = var.tags
}
# ECS & ALB Info
module "ecs_cluster" {
  source              = "./modules/compute/ecs"
  cluster_name        = var.ecs_cluster_name
  private_subnet_ids  = module.subnets.private_subnet_ids
  security_group_id   = module.sg.ecs_sg_id
  execution_role_arn  = var.ecs_execution_role_arn
  container_image     = var.ecs_container_image
}
module "codedeploy" {
  source                  = "./modules/devops/CodeDeploy"
  app_name                = var.app_name
  deployment_group_name   = var.deployment_group_name
  codedeploy_service_role_arn = var.codedeploy_service_role_arn
  ecs_cluster_name        = var.ecs_cluster_name
  ecs_service_name        = var.ecs_service_name
  prod_listener_arn       = var.prod_listener_arn
  test_listener_arn       = var.test_listener_arn
  prod_target_group       = var.prod_target_group
  test_target_group       = var.test_target_group
}
module "codebuild" {
  source                  = "./modules/devops/CodeBuild"
  project_name            = var.project_name
  description             = var.description
  codebuild_service_role_arn = var.codebuild_service_role_arn
  ecr_repo_url            = var.ecr_repo_url
  source_type             = var.source_type
  source_location         = var.source_location
  buildspec_path          = var.buildspec_path
  cloudwatch_group        = var.cloudwatch_group
  cloudwatch_stream       = var.cloudwatch_stream
  logs_s3_bucket          = var.logs_s3_bucket
  logs_s3_path            = var.logs_s3_path
}
module "codepipeline" {
  source                  = "./modules/devops/CodePipeline"
  pipeline_name           = var.pipeline_name
  pipeline_role_arn       = var.pipeline_role_arn
  artifact_bucket         = var.artifact_bucket
  kms_key_arn             = var.kms_key_arn
  source_provider         = var.source_provider
  source_owner            = var.source_owner
  source_configuration    = var.source_configuration
  codebuild_project_name  = var.codebuild_project_name
  codedeploy_app_name     = var.codedeploy_app_name
  codedeploy_deployment_group = var.codedeploy_deployment_group
  tags                    = var.tags
}