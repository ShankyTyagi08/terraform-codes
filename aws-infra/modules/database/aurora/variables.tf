variable "vpc_id" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "db_name" {
  type    = string
  default = "auroradb"
}

variable "engine_version" {
  type    = string
  default = "5.7.mysql_aurora.2.07.1"
}
