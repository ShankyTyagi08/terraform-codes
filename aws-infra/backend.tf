/* terraform {
  backend "s3" {
    bucket         = "var.bucket_name"
    key            = "dev/devops/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
*/