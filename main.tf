# Terraformバージョン、プロバイダーバージョンの定義
terraform {
  required_version = "0.15.3"

  required_providers {
    aws = "3.40.0"
  }
}

# 変数定義
variable "sysname" {
  default = "tfdock"
}

module "describe_regions_for_ec2" {
  source     = "./iam_role"
  name       = "describe-regions-for-ec2"
  identifier = "ec2.amazonaws.com"
  policy     = data.aws_iam_policy_document.allow_describe_regions.json
}

module "example_sg" {
  source      = "./security_group"
  name        = "module-sg"
  vpc_id      = aws_vpc.main.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}
