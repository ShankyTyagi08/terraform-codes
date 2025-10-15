variable "app_name" {}
variable "deployment_group_name" {}
variable "codedeploy_service_role_arn" {}

variable "ecs_cluster_name" {}
variable "ecs_service_name" {}

variable "prod_listener_arn" {}
variable "test_listener_arn" {}
variable "prod_target_group" {}
variable "test_target_group" {}

variable "tags" {
  type = map(string)
  default = {}
}
