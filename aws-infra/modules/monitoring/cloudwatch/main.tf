resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/aws/app/logs"
  retention_in_days = 14 # Retain logs for 14 days
  tags = {
    Environment = "Production"
    Application = "GenAIApp"
    }
}
