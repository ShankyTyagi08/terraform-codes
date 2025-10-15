variable "bucket_name" {
  description = "Name of the logging bucket"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
