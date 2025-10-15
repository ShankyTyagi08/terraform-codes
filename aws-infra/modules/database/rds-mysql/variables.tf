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
  default = "mysqldb"
}

variable "engine_version" {
  type    = string
  default = "8.0"
}
