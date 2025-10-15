resource "aws_wafv2_web_acl" "alb_acl" {
  name        = var.web_acl_name
  description = var.web_acl_description
  scope       = "REGIONAL" # "REGIONAL" for ALB; use "CLOUDFRONT" for CloudFront
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "albWebAcl"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "block-bad-user-agent"
    priority = 1
    action {
      block {}
    }

    statement {
      byte_match_statement {
        search_string = "BadBot"

        field_to_match {
          single_header {
            name = "User-Agent"
          }
        }

        positional_constraint = "CONTAINS"

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "blockBadUserAgent"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_web_acl_association" "alb_attach" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.alb_acl.arn
}