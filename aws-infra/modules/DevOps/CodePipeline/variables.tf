variable "pipeline_name" {}
variable "pipeline_role_arn" {}
variable "artifact_bucket" {}
variable "kms_key_arn" {}

# Source stage
variable "source_provider" {}
variable "source_owner" {}
variable "source_configuration" {
  type = map(string)
}

# CodeBuild
variable "codebuild_project_name" {}

# CodeDeploy
variable "codedeploy_app_name" {}
variable "codedeploy_deployment_group" {}

variable "tags" {
  type = map(string)
  default = {}
}
