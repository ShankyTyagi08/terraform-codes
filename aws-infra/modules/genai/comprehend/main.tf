# Comprehend is managed through IAM permissions and is used via API
resource "aws_iam_policy" "comprehend_policy" {
  name        = "ComprehendFullAccessPolicy"
  description = "IAM policy for Comprehend access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "comprehend:*"
        ],
        Resource = "*"
      }
    ]
  })
}