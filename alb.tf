# ===============================================
# ALB
# ===============================================
# 1. ALB
resource "aws_lb" "web" {
  name                       = "prod-web-alb"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false # 削除保護する場合はtrue

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id,
  ]

  access_logs {
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

# 2. Security group
module "http_sg" {
  source      = "./security_group"
  name        = "http_sg"
  vpc_id      = aws_vpc.main.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source      = "./security_group"
  name        = "https_sg"
  vpc_id      = aws_vpc.main.id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
}

module "http_redirect_sg" {
  source      = "./security_group"
  name        = "http_redirect_sg"
  vpc_id      = aws_vpc.main.id
  port        = 8080
  cidr_blocks = ["0.0.0.0/0"]
}

# 3. ALB Listener
# 3-1. HTTP listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This is [HTTP]."
      status_code  = "200"
    }
  }
}

# 3-2. HTTPS listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.slothprev.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This is HTTPS response."
      status_code  = "200"
    }
  }
}

# 3-3. Redirect listener
resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.web.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}