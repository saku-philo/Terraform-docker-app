# ===============================================
# ALB
# ===============================================
# 1. ALB
resource "aws_lb" "web" {
  name                       = "prod-web-alb"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = true

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id,
  ]

  access_log {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id,
  ]
}

output "alb_dns_name" {
  value = aws_lb.web.dns_name
}
