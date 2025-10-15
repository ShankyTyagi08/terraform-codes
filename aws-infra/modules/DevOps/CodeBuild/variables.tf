variable "project_name" {}
variable "description" {}

variable "source_type" {}
variable "source_location" {}
variable "buildspec_path" {}

variable "ecr_repo_url" {}

variable "cloudwatch_group" {}
variable "cloudwatch_stream" {}
variable "logs_s3_bucket" {}
variable "logs_s3_path" {}

variable "codebuild_service_role_arn" {}

variable "tags" {
  type = map(string)
  default = {}
}
