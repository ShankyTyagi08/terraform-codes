# You can control access to Bedrock via IAM permissions
resource "aws_iam_policy" "bedrock_access" {
  name        = "BedrockFullAccessPolicy"
  description = "IAM policy for full access to Amazon Bedrock"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "bedrock:*"
        ],
        Resource = "*"
      }
    ]
  })
}