variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
  default     = "/aws/app/logs"
}
