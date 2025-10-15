variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}
variable "environment" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
  default     = "prod"
}
variable "alert_email" {
  description = "The email address to receive SNS alerts"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
  default = "1234567890123" # Replace with your actual AWS account ID
}
variable "vpc_id" {
  description = "The VPC ID where resources will be deployed"
  type        = string
  default     = "GenAI-VPC" # Replace with your actual VPC ID
} 
variable "db_subnet_ids" {
  description = "List of subnet IDs for the RDS database"
  type        = list(string)
  default     = []
}
variable "security_group_ids" {
  description = "List of security group IDs for the RDS database"
  type        = list(string)
  default = [ "value" ]
}
variable "engine_version" {
  description = "The version of the MySQL engine to use"
  type        = string
  default     = "8.0"
}
variable "rds_mysql_username" {
  description = "The username for the RDS MySQL database"
  type        = string
}
variable "rds_mysql_password" {
  description = "The password for the RDS MySQL database"
  type        = string
  sensitive   = true
}
variable "rds_mysql_db_name" {
  description = "The name of the RDS MySQL database"
  type        = string
}
variable "aurora_master_username" {
  description = "The master username for the Aurora database"
  type        = string
}
variable "aurora_master_password" {
  description = "The master password for the Aurora database"
  type        = string
  sensitive   = true
}
variable "aurora_db_name" {
  description = "The name of the Aurora database"
  type        = string
}
variable "log_bucket_suffix" {
  description = "Suffix for the S3 logging bucket"
  type        = string
  default     = "logs-dev"
}
variable "sns_alert_email" {
  description = "Email address for SNS alerts"
  type        = string
  default     = "shanky.tyagi@aeonx.digital" # Replace with your actual email
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = ""
}
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = []
}
variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = []
}
variable "rds_instance_class" {
  description = "The instance class for the RDS MySQL database"
  type        = string
  default     = "db.t3.medium"
}
variable "rds_allocated_storage" {
  description = "The allocated storage size for the RDS MySQL database in GB"
  type        = number
  default     = 20
}
variable "rds_skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the RDS MySQL database"
  type        = bool
  default     = true
}
variable "rds_publicly_accessible" {
  description = "Whether the RDS MySQL database should be publicly accessible"
  type        = bool
  default     = false
}
variable "rds_db_subnet_group_name" {
  description = "The name of the RDS DB subnet group"
  type        = string
  default     = "mysql-subnet-group"
}
variable "rds_db_instance_identifier" {
  description = "The identifier for the RDS MySQL database instance"
  type        = string
  default     = "mysql-instance"
}
variable "aurora_instance_class" {
  description = "The instance class for the Aurora database"
  type        = string
  default     = "db.r5.large"
}
variable "aurora_allocated_storage" {
  description = "The allocated storage size for the Aurora database in GB"
  type        = number
  default     = 20
}
variable "aurora_skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the Aurora database"
  type        = bool
  default     = true
}
variable "aurora_publicly_accessible" {
  description = "Whether the Aurora database should be publicly accessible"
  type        = bool
  default     = false
}
variable "aurora_db_subnet_group_name" {
  description = "The name of the Aurora DB subnet group"
  type        = string
  default     = "aurora-subnet-group"
}
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Owner       = "aeonx-devops"
    Environment = "prod"
    Project     = "terraform-infra"
  }
  
}
variable "ec2_instance_type" {
  description = "The instance type for EC2 instances"
  type        = string
  default     = "t3.micro"
  
}
variable "ami_id" {
  description = "The AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Update with latest Amazon Linux AMI ID
}
variable "key_name" {
  description = "The key pair name for EC2 instances"
  type        = string
  default     = "genAI.pem" # Update with your key pair name
}
variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
  default     = "my-ecs-cluster"
}
variable "container_image" {
  description = "The Docker image to use in ECS tasks"
  type        = string
  default     = "nginx:latest"
}
variable "execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  type        = string
  default = "values.default_execution_role_arn" # Replace with your actual execution role ARN
}
variable "ec2_launch_template_name" {
  description = "The name of the EC2 launch template"
  type        = string
  default     = "GenAI-Web-LaunchTemplate"
  
}
variable "codebuild" {
  description = "CodeBuild configuration"
  type = object({
    project_name               = string
    description                = string
    service_role_arn           = string
    ecr_repo_url               = string
    source_type                = string
    source_location            = string
    buildspec_path             = string
    cloudwatch_group           = string
    cloudwatch_stream          = string
    logs_s3_bucket             = string
    logs_s3_path               = string
  })
  
}
variable "codedeploy" {
  description = "CodeDeploy configuration"
  type = object({
    app_name                = string
    deployment_group_name   = string
    service_role_arn        = string
  })
  
}
variable "codepipeline" {
  description = "CodePipeline configuration"
  type = object({
    pipeline_name           = string
    pipeline_role_arn       = string
    artifact_bucket         = string
    kms_key_arn             = string
    source_provider         = string
    source_owner            = string
    source_configuration    = map(string)
    codebuild_project_name  = string
    codedeploy_app_name     = string
    codedeploy_deployment_group = string
  })
  
}
variable "ecs_service" {
  description = "ECS service configuration"
  type = object({
    service_name            = string
    cluster_name            = string
    task_definition_arn     = string
    desired_count           = number
    launch_type             = string
    load_balancer_target_group_arn = string
    health_check_grace_period_seconds = number
  })
  
}
variable "source_owner" {
  description = "The owner of the source repository for CodePipeline"
  type        = string
  default     = "ThirdParty" # Replace with your actual source owner
}
variable "test_listener_arn" {
  description = "ARN of the test ALB listener"
  type        = string
  default     = "arn:aws:elasticloadbalancing:us-east-2:123456789012:listener/app/my-alb/abc123" # Replace with your actual listener ARN
}

variable "prod_listener_arn" {
  description = "ARN of the production ALB listener"
  type        = string
  default     = "arn:aws:elasticloadbalancing:us-east-2:123456789012:listener/app/my-alb/xyz456" # Replace with your actual listener ARN
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
  default = "values.default_service_name" # Replace with your actual ECS service name
}

variable "test_target_group" {
  description = "ARN of the test target group"
  type        = string
  default = "values.default_test_target_group" # Replace with your actual test target group ARN
}

variable "prod_target_group" {
  description = "ARN of the production target group"
  type        = string
  default = "values.default_target_group" # Replace with your actual target group ARN
}
# CodeDeploy
variable "deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  type        = string
  default     = "ecs-deployment-group"
}
variable "codedeploy_service_role_arn" {
  description = "ARN of the CodeDeploy service role"
  type        = string
  default     = "arn:aws:iam::123456789012:role/CodeDeployServiceRole" # Replace with your actual role ARN
}

# CodeBuild
variable "project_name" {
  description = "Name of the CodeBuild project"
  type        = string
  default     = "ECS-Blue-Green-CodeBuild"
}
variable "description" {
  description = "Description of the CodeBuild project"
  type        = string
  default     = "CodeBuild Project for ECS Blue/Green Deployment"
}
variable "codebuild_service_role_arn" {
  description = "ARN of the CodeBuild service role"
  type        = string
  default     = "arn:aws:iam::123456789012:role/CodeBuildServiceRole" # Replace with your actual role ARN
}
//variable "ecr_repo_url" {}
variable "source_type" {
  description = "Type of source for CodeBuild (e.g., GITHUB, S3)"
  type        = string
  default     = "GITHUB" # Replace with your actual source type
}
variable "source_location" {
  description = "Location of the source code for CodeBuild"
  type        = string
  default     = ""
}
variable "logs_s3_bucket" {
  description = "S3 bucket for CodeBuild logs"
  type        = string
  default     = "my-codebuild-logs-bucket" # Replace with your actual S3 bucket name
}
variable "logs_s3_path" {
  description = "S3 path for CodeBuild logs"
  type        = string
  default     = "logs/codebuild" # Replace with your actual S3 path
}

# CodePipeline
variable "pipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
  default     = "ECS-Blue-Green-Pipeline"
}
variable "pipeline_role_arn" {
  description = "ARN of the CodePipeline service role"
  type        = string
  default     = "arn:aws:iam::123456789012:role/CodePipelineServiceRole" # Replace with your actual role ARN
}
variable "artifact_bucket" {
  description = "Name of the S3 bucket for CodePipeline artifacts"
  type        = string
  default     = "my-codepipeline-artifacts" # Replace with your actual S3 bucket name
}
variable "kms_key_arn" {
  description = "ARN of the KMS key for CodePipeline"
  type        = string
  default     = "arn:aws:kms:us-east-2:123456789012:key/your-kms-key-id" # Replace
}
variable "source_provider" {
  description = "Source provider for CodePipeline"
  type        = string
  default     = "GitHub" # Replace with your actual source provider
}
variable "source_configuration" {
  type = map(string)
  description = "Configuration for the source stage in CodePipeline"
  default = {
    Owner      = "your-github-username"
    Repo       = "your-repo-name"
    Branch     = "main"
  }
}

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  type        = string
  default = "CodeBuild-Project"
}
variable "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  type        = string
  default = "CodeDeploy-App"
}
variable "codedeploy_deployment_group" {
  description = "Name of the CodeDeploy deployment group"
  type        = string
  default = "CodeDeploy-Deployment-Group"
}
# (existing variable declarations)
variable "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role"
  type        = string
  default = "values.default_execution_role_arn" # Replace with your actual execution role ARN
}

variable "ecs_container_image" {
  description = "ECS container image to deploy"
  type        = string
  default = "values.default_container_image" # Replace with your actual container image URI
}
variable "app_name" {
  description = "Name of the application for CodeDeploy"
  type        = string
  default = "GenAI-Web-App"
  
}
variable "artifact_bucket_name" {
  description = "Name of the S3 bucket for CodePipeline artifacts"
  type        = string
  default     = "genai-web-artifacts"
  
}
variable "buildspec_path" {
  description = "Path to the buildspec file for CodeBuild"
  type        = string
  default     = "buildspec.yml"
  
}
variable "cloudwatch_group" {
  description = "CloudWatch log group for CodeBuild"
  type        = string
  default     = "/genAI/genai-web-build"
  
}
variable "cloudwatch_stream" {
  description = "CloudWatch log stream for CodeBuild"
  type        = string
  default     = "genai-web-build-stream"
  
}
variable "ecsTaskExecutionRoleArn" {
  description = "ARN of the ECS task execution role"
  type        = string
  default     = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole" # Replace with your actual role ARN
  
}
variable "ecr_repo_url" {
  description = "ECR repository URL for the Docker image"
  type        = string
  default     = "123456789012.dkr.ecr.us-east-2.amazonaws.com/my-ecr-repo" # Replace with your actual ECR repo URL
  
}