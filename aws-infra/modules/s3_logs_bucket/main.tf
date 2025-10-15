resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  force_destroy = true

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "expire-logs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowLogServicesWrite"
        Effect    = "Allow"
        Principal = {
          Service = [
            "cloudtrail.amazonaws.com",
            "vpc-flow-logs.amazonaws.com",
            "elasticloadbalancing.amazonaws.com"
          ]
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
      },
      {
        Sid       = "AllowServicesBucketAcl"
        Effect    = "Allow"
        Principal = {
          Service = [
            "cloudtrail.amazonaws.com",
            "vpc-flow-logs.amazonaws.com",
            "elasticloadbalancing.amazonaws.com"
          ]
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.this.arn
      }
    ]
  })
}
