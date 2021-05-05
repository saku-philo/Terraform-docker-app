# ===============================================
# Route53
# ===============================================
# 1. Host zone
data "aws_route53_zone" "slothprev" {
  name = "slothprev.com"
}

# 2. DNSレコード
resource "aws_route53_record" "slothprev" {
  zone_id = data.aws_route53_zone.slothprev.zone_id
  name    = data.aws_route53_zone.slothprev.name
  type    = "A"

  alias {
    name                   = aws_lb.web.dns_name
    zone_id                = aws_lb.web.zone_id
    evaluate_target_health = true
  }
}

# 3. 出力
output "domain_name" {
  value = aws_route53_record.slothprev.name
}