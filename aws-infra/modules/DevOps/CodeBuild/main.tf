resource "aws_codebuild_project" "this" {
  name          = var.project_name
  description   = var.description
  service_role  = var.codebuild_service_role_arn
  build_timeout = 60

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true  # Required for Docker builds
    environment_variable {
      name  = "REPOSITORY_URI"
      value = var.ecr_repo_url
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.cloudwatch_group
      stream_name = var.cloudwatch_stream
    }
    s3_logs {
      status             = "ENABLED"
      location           = "${var.logs_s3_bucket}/${var.logs_s3_path}"
      encryption_disabled = false
    }
  }

  source {
    type      = var.source_type  # GITHUB, CODECOMMIT, S3
    location  = var.source_location
    buildspec = var.buildspec_path
  }

  tags = var.tags
}