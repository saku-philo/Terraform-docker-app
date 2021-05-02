variable "name" {}
variable "vpc_id" {}
variable "port" {}
variable "cidr_blocks" {
  type = list(string)
}

resource "aws_security_group" "default" {
  name = var.name
  vpc_id = var.vpc_id
}
