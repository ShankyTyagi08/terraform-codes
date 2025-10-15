provider "aws" {
  region = "ap-south-1"

  assume_role {
    role_arn     = "arn:aws:iam::204917013198:role/TerraformExecutionRole"
    session_name = "tf-apply"
  }
}