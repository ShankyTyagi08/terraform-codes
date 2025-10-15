resource "aws_cloudtrail" "main" {
  name                          = "account-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]  # Optional: Monitor S3
    }
  }
}
resource "aws_cloudtrail" "this" {
  name                          = "org-cloudtrail"
  s3_bucket_name                = module.logs_bucket.bucket_name
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
}
