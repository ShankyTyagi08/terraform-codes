# Environment
environment = "prod"

# RDS MySQL
rds_mysql_username = "admin"
rds_mysql_password = "StrongPassword123!"
rds_mysql_db_name  = "appdb"

# RDS Aurora
aurora_master_username = "auroraadmin"
aurora_master_password = "AuroraStrongPass456!"
aurora_db_name         = "auroradb"

# S3 Logging Bucket Suffix
log_bucket_suffix = "logs-prod" # final bucket name: "aeonx-central-logs-${log_bucket_suffix}"

# SNS Alerts
alert_email = "shanky.tyagi@aeonx.digital"

# VPC Config (Optional if already defined)
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

# General Tags
tags = {
  Environment = "prod"
  Project     = "ecs-blue-green"
}

# ECS Cluster and Service
ecs_cluster_name = "my-ecs-cluster"
ecs_service = {
  service_name             = "my-ecs-service"
  prod_listener_arn        = "arn:aws:elasticloadbalancing:region:account-id:listener/app/my-alb/abc123"
  test_listener_arn        = "arn:aws:elasticloadbalancing:region:account-id:listener/app/my-alb/xyz456"
  prod_target_group        = "prod-target-group"
  test_target_group        = "test-target-group"
  container_image          = "your-container-image-uri"
  execution_role_arn       = "arn:aws:iam::123456789012:role/ecsExecutionRole"  # replace with actual
  task_execution_role_arn  = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"  # if different
  security_group_ids       = ["sg-0123456789abcdef0"]  # replace with actual SG IDs
  vpc_id                   = "vpc-0123456789abcdef0"  # replace with your VPC ID
}

# CodeDeploy Configuration
codedeploy = {
  app_name                  = "ecs-codedeploy-app"
  deployment_group_name     = "ecs-deployment-group"
  service_role_arn          = "arn:aws:iam::123456789012:role/CodeDeployServiceRole"
}

# CodeBuild Configuration
codebuild = {
  project_name               = "ecs-docker-build"
  description                = "Build and push Docker image to ECR"
  service_role_arn           = "arn:aws:iam::123456789012:role/CodeBuildServiceRole"
  ecr_repo_url               = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-ecr-repo"
  source_type                = "GITHUB"
  source_location            = "https://github.com/your-org/your-repo"
  buildspec_path             = "buildspec.yml"
  cloudwatch_group           = "/aws/codebuild/ecs-docker-build"
  cloudwatch_stream          = "ecs-docker-stream"
  logs_s3_bucket             = "my-codebuild-logs-bucket"
  logs_s3_path               = "logs/codebuild"
}

# CodePipeline Configuration
codepipeline = {
  pipeline_name           = "ecs-blue-green-pipeline"
  pipeline_role_arn       = "arn:aws:iam::123456789012:role/CodePipelineServiceRole"
  artifact_bucket         = "my-codepipeline-artifacts"
  kms_key_arn             = "arn:aws:kms:us-east-1:123456789012:key/xxxxxxxx-yyyy-zzzz-aaaa-bbbbbbbbbbbb"
  source_provider         = "GitHub"
  source_owner            = "ThirdParty"

  source_configuration = {
    Owner      = "your-github-username"
    Repo       = "your-repo-name"
    Branch     = "main"
    OAuthToken = "YOUR_GITHUB_OAUTH_TOKEN"  # Store securely, or use SSM Parameter Store in practice
  }
}
