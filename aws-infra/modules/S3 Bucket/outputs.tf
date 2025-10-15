output "s3_bucket_name" {
  description = "Name of the secure S3 bucket"
  value       = aws_s3_bucket.secure_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the secure S3 bucket"
  value       = aws_s3_bucket.secure_bucket.arn
}

output "kms_key_arn" {
  description = "KMS Key ARN used for encryption"
  value       = aws_kms_key.s3_key.arn
}