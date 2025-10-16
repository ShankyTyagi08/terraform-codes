variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "account_id" {
  type    = string
  default = "184585832362"
}
variable "state_bucket" {
  type    = string
  default = "aeonx-tfstates-backend"
}
variable "lock_table" {
  type    = string
  default = "terraform-locks"
}

# Principals allowed to assume the TerraformWorkRole (add SSO role ARNs/users as needed)
variable "trusted_principals" {
  type = list(object({
    type        = string
    identifiers = list(string)
  }))
  default = [
    { type = "AWS", identifiers = ["arn:aws:iam::184585832362:root"] }
  ]
}
