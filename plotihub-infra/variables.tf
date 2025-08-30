variable "project" { type = string }
variable "env" { type = string }
variable "region_primary" { type = string }
variable "vpc_cidr" { type = string }
variable "db_port" {
  type    = number
  default = 5432
}

