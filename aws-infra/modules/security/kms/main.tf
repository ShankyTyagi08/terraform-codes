resource "aws_kms_key" "main" {
  description             = "KMS key for encrypting S3, RDS, CloudTrail"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

output "kms_key_arn" {
  value = aws_kms_key.main.arn
}
