terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  account_id      = var.account_id
  project_tag_key = "Project"
  project_tag_val = "Ashapura-Logistic"
  bucket_name     = var.state_bucket
  ddb_table_name  = var.lock_table
}

# ---------------------
# Remote state backend (S3 + DynamoDB)
# ---------------------
resource "aws_s3_bucket" "tfstate" {
  bucket = local.bucket_name
  tags = {
    (local.project_tag_key) = local.project_tag_val
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "locks" {
  name         = local.ddb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    (local.project_tag_key) = local.project_tag_val
  }
}

# ---------------------
# IAM PERMISSIONS BOUNDARY
# ---------------------
data "aws_iam_policy_document" "permissions_boundary" {
  statement {
    sid       = "DenyOutsideRegion"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }

  statement {
    sid       = "DenyUntaggedOrWrongProject"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringNotEquals"
      variable = "aws:RequestTag/Project"
      values   = [local.project_tag_val]
    }
  }

  statement {
    sid    = "RequireProjectTagOnCreate"
    effect = "Deny"
    actions = [
      "ec2:RunInstances", "ec2:Create*", "s3:CreateBucket", "lambda:Create*", "logs:Create*",
      "events:PutRule", "events:PutTargets", "iam:Create*", "iam:PutRolePolicy", "iam:AttachRolePolicy",
      "cloudwatch:Put*", "sns:CreateTopic", "sqs:CreateQueue", "ecr:CreateRepository", "rds:Create*",
      "dynamodb:CreateTable", "autoscaling:Create*", "elasticloadbalancing:Create*"
    ]
    resources = ["*"]
    condition {
      test     = "Null"
      variable = "aws:RequestTag/Project"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "permissions_boundary" {
  name        = "TerraformProjectBoundary"
  description = "Boundary limiting region to ${var.region} and enforcing Project=${local.project_tag_val}"
  policy      = data.aws_iam_policy_document.permissions_boundary.json
  tags = {
    (local.project_tag_key) = local.project_tag_val
  }
}

# ---------------------
# Terraform WORK ROLE (assumed by humans/CI)
# ---------------------
data "aws_iam_policy_document" "work_role_trust" {
  # Allow CodeBuild to assume (CI)
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }

  # Also allow your human/admin/SSO principals to assume
  dynamic "statement" {
    for_each = var.trusted_principals
    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type        = statement.value.type
        identifiers = statement.value.identifiers
      }
    }
  }
}

resource "aws_iam_role" "terraform_work_role" {
  name                 = "TerraformWorkRole"
  path                 = "/terraform/"
  assume_role_policy   = data.aws_iam_policy_document.work_role_trust.json
  permissions_boundary = aws_iam_policy.permissions_boundary.arn
  tags = {
    (local.project_tag_key) = local.project_tag_val
  }
}


# Project-scoped inline policy (adjust services per your modules)
data "aws_iam_policy_document" "work_policy" {
  statement {
    sid    = "EC2Core"
    effect = "Allow"
    actions = [
      "ec2:Describe*", "ec2:CreateTags", "ec2:DeleteTags",
      "ec2:RunInstances", "ec2:TerminateInstances",
      "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress", "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:CreateSubnet", "ec2:DeleteSubnet",
      "ec2:CreateInternetGateway", "ec2:AttachInternetGateway", "ec2:DeleteInternetGateway",
      "ec2:CreateRouteTable", "ec2:DeleteRouteTable", "ec2:CreateRoute", "ec2:DeleteRoute",
      "ec2:AssociateRouteTable", "ec2:DisassociateRouteTable",
      "ec2:AllocateAddress", "ec2:ReleaseAddress", "ec2:AssociateAddress", "ec2:DisassociateAddress"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "ELBASG"
    effect    = "Allow"
    actions   = ["elasticloadbalancing:*", "autoscaling:*"]
    resources = ["*"]
  }

  statement {
    sid       = "LogsEventsCloudWatch"
    effect    = "Allow"
    actions   = ["logs:*", "events:*", "cloudwatch:*"]
    resources = ["*"]
  }

  statement {
    sid    = "S3ProjectBuckets"
    effect = "Allow"
    actions = [
      "s3:CreateBucket", "s3:PutBucketTagging", "s3:PutBucketPolicy", "s3:PutEncryptionConfiguration",
      "s3:PutBucketVersioning", "s3:PutLifecycleConfiguration", "s3:DeleteBucket",
      "s3:ListBucket", "s3:GetBucketLocation", "s3:PutBucketPublicAccessBlock",
      "s3:GetBucketPolicy", "s3:DeleteBucketPolicy", "s3:GetEncryptionConfiguration", "s3:GetBucketTagging"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "IAMLimitedForServices"
    effect = "Allow"
    actions = [
      "iam:CreateRole", "iam:DeleteRole", "iam:CreatePolicy", "iam:DeletePolicy",
      "iam:AttachRolePolicy", "iam:DetachRolePolicy", "iam:PutRolePolicy", "iam:DeleteRolePolicy",
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/terraform/*",
      "arn:aws:iam::${local.account_id}:policy/terraform/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PermissionsBoundary"
      values   = [aws_iam_policy.permissions_boundary.arn]
    }
  }

  statement {
    sid       = "KMSIfUsed"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey", "kms:DescribeKey", "kms:CreateGrant", "kms:RetireGrant"]
    resources = ["arn:aws:kms:${var.region}:${local.account_id}:key/*"]
  }
}

resource "aws_iam_role_policy" "work_inline" {
  name   = "TerraformProjectScopedAccess"
  role   = aws_iam_role.terraform_work_role.id
  policy = data.aws_iam_policy_document.work_policy.json
}

# ---------------------
# Minimal backend access policy (attach to Work Role)
# ---------------------
data "aws_iam_policy_document" "backend_access" {
  statement {
    sid       = "S3ListBucketPrefix"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${local.bucket_name}"]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["ashapura-logistic/*"]
    }
  }

  statement {
    sid       = "S3ObjectCrud"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${local.bucket_name}/ashapura-logistic/*"]
  }

  statement {
    sid       = "DDBLockTable"
    effect    = "Allow"
    actions   = ["dynamodb:DescribeTable", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:UpdateItem"]
    resources = ["arn:aws:dynamodb:${var.region}:${local.account_id}:table/${local.ddb_table_name}"]
  }
}

resource "aws_iam_policy" "backend_access" {
  name        = "TerraformStateBackendAccess"
  description = "Access to S3 state prefix and DynamoDB lock table"
  policy      = data.aws_iam_policy_document.backend_access.json
  tags = {
    (local.project_tag_key) = local.project_tag_val
  }
}

resource "aws_iam_role_policy_attachment" "work_backend_attach" {
  role       = aws_iam_role.terraform_work_role.name
  policy_arn = aws_iam_policy.backend_access.arn
}

# ---------------------
# CodeBuild role that can assume TerraformWorkRole (no admin)
# ---------------------
data "aws_iam_policy_document" "codebuild_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "CodeBuildTerraformRole"
  assume_role_policy = data.aws_iam_policy_document.codebuild_trust.json
  tags = {
    (local.project_tag_key) = local.project_tag_val
  }
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    sid       = "AllowAssumeTerraformWorkRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.terraform_work_role.arn]
  }

  statement {
    sid    = "LogsAndArtifacts"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents",
      "s3:GetObject", "s3:PutObject", "s3:ListBucket"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_inline" {
  name   = "CodeBuildTerraformPolicy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_policy.json
}
