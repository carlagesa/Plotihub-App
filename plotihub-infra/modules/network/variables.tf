variable "name" { type = string }
variable "cidr_block" { type = string }
variable "azs" { type = list(string) }
variable "private_app_cidrs" { type = list(string) }
variable "private_db_cidrs" { type = list(string) }
variable "db_port" { type = number }
variable "tags" {
  type    = map(string)
  default = {}
}

