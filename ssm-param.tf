resource "aws_ssm_parameter" "db_username" {
  name        = "/db/username"
  value       = "root"
  type        = "String"
  description = "データベースユーザー名"
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/db/password"
  value       = "uninitialized" // apply後にCLIを使用して上書き
  type        = "SecureString"
  description = "データベースパスワード"

  lifecycle {
    ignore_changes = [value]
  }
}