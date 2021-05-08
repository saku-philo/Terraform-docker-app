# ===============================================
# KMS
# ===============================================
# 1. KMS
resource "aws_kms_key" "tfdock" {
  description             = "tfdock app Customer Master Key"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 30
}
