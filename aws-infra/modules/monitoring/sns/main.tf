resource "aws_sns_topic" "alerts" {
  name = "infra-alerts"
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email  # Set in variables.tf or tfvars
}
