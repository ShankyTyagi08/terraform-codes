resource "aws_codepipeline" "this" {
  name     = var.pipeline_name
  role_arn = var.pipeline_role_arn
  artifact_store {
    location = var.artifact_bucket
    type     = "S3"

    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = var.source_owner
      provider         = var.source_provider  # GitHub, S3, CodeCommit
      version          = "1"
      output_artifacts = ["source_output"]
      configuration    = var.source_configuration
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeployToECS"
      input_artifacts  = ["build_output"]
      version          = "1"
      configuration = {
        ApplicationName                = var.codedeploy_app_name
        DeploymentGroupName           = var.codedeploy_deployment_group
        TaskDefinitionTemplateArtifact = "build_output"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "build_output"
        AppSpecTemplatePath            = "appspec.yaml"
      }
    }
  }

  tags = var.tags
}
