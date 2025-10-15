variable "web_acl_name" {
  type        = string
  description = "Name of the WAF Web ACL"
  default     = "alb-web-acl"
}

variable "web_acl_description" {
  type        = string
  description = "Description for the WAF Web ACL"
  default     = "WAF Web ACL for ALB protection"
}

variable "alb_arn" {
  type        = string
  description = "ARN of the Application Load Balancer to associate with the WAF Web ACL"
}
