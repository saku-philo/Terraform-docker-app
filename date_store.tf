# ===============================================
# RDS
# ===============================================
# 1. DBパラメータグループ
resource "aws_db_parameter_group" "tfdock-rds" {
  name   = "tfdock-rds"
  family = "mysql5.7"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

# 2. DBオプショングループ
resource "aws_db_option_group" "tfdock-rds" {
  name                 = "tfdock-rds"
  engine_name          = "mysql"
  major_engine_version = "5.7"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
}
