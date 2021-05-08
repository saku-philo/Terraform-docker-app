resource "aws_kms_key" "tfdoc" {
  description = "tfdoc app Customer Master Key"
  enable_key_rotation = true
  is_enabled = true
  deletion_window_in_days = 30
}