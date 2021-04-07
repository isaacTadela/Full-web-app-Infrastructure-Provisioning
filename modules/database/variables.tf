variable "azs" {}

variable "vpc_id" {}

variable "private_subnet" {}

variable "environment" {}

variable "multi_az" {
  default = false
}

variable "username" {
  default = "username"
}

variable "password" {
  default = "password"
}

variable "port" {
  default = "3306"
}

variable "protocol" {
  default = "TCP"
}

variable "apply_immediately" {
  default = true
}

variable "publicly_accessible" {
  default = "true"
}

variable "engine" {
  default = "mysql"
}

variable "engine_version" {
  default = "5.7.26"
}

variable "instance_class" {
  default = "db.t2.micro"
}

variable "name" {
  default = "rds_db"
}

variable "storage_type" {
  default = "standard"
}

variable "allocated_storage" {
  default = "20"
}
variable "availability_zone" {
  default = "eu-west-3a"
}

variable "skip_final_snapshot" {
  default = true
}