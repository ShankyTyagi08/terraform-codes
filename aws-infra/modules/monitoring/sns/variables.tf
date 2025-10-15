variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "alert_email" {
  description = "Email for receiving CloudWatch/SNS alerts"
  type        = string
}