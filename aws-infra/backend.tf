terraform {
  backend "s3" {
    bucket         = "aeonx-tfstates-backend"
    key            = "ashapura-logistic/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
