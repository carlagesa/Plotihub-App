variable "primary_region" {
  type    = string
  default = "af-south-1"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.small"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "min_instance_count" {
  type    = number
  default = 2
}

variable "max_instance_count" {
  type    = number
  default = 4
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "backup_retention_days" {
  type    = number
  default = 30
}

variable "tags" {
  type = map(string)
  default = {
    Project = "Plotihub"
  }
}
