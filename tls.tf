# ===============================================
# TLS
# ===============================================
# 1. AWS Certificate Manager
resource "aws_acm_certificate" "slothprev" {
  domain_name               = aws_route53_record.slothprev.name
  subject_alternative_names = ["*.slothprev.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# 2. 検証用DNSレコード
resource "aws_route53_record" "slothprev_certificate" {
  name    = tolist(aws_acm_certificate.slothprev.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.slothprev.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.slothprev.domain_validation_options)[0].resource_record_value]
  zone_id = data.aws_route53_zone.slothprev.id
  ttl     = 60
}

# 3. 検証の待機
resource "aws_acm_certificate_validation" "slothprev_certificate" {
  certificate_arn = aws_acm_certificate.slothprev.arn
  validation_record_fqdns = [
    aws_route53_record.slothprev_certificate.fqdn
  ]
}