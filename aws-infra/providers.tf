provider "aws" {
  region = "ap-south-1"

  assume_role {
    role_arn     = "arn:aws:iam::184585832362:role/terraform/TerraformWorkRole"
    session_name = "tf-apply"
  }
}
