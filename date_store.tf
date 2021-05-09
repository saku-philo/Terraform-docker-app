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

# 3. DBサブネットグループ
resource "aws_db_subnet_group" "tfdock-rds" {
  name = "tfdock-rds"
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

# 4. DBインスタンス
resource "aws_db_instance" "tfdock-rds" {
  identifier                 = "tfdock-rds"
  engine                     = "mysql"
  engine_version             = "5.7.25"
  instance_class             = "db.t3.small"
  allocated_storage          = "20"
  storage_type               = "gp2"
  storage_encrypted          = true
  kms_key_id                 = aws_kms_key.tfdock.arn
  username                   = "admin"
  password                   = "ModifyMe!" // apply後、CLIで変更
  multi_az                   = true
  publicly_accessible        = false
  backup_window              = "09:10-09:40"
  maintenance_window         = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  deletion_protection        = false // 削除の際falseにしてapply
  skip_final_snapshot        = true  // 削除の際trueにしてapply
  port                       = 3306
  apply_immediately          = true // true時apply後にrebootされる
  vpc_security_group_ids     = [module.mysql_sg.security_group_id]
  parameter_group_name       = aws_db_parameter_group.tfdock-rds.name
  option_group_name          = aws_db_option_group.tfdock-rds.name
  db_subnet_group_name       = aws_db_subnet_group.tfdock-rds.name

  lifecycle {
    ignore_changes = [password]
  }
}

# 5. セキュリティグループ
module "mysql_sg" {
  source      = "./security_group"
  name        = "mysql-sg"
  vpc_id      = aws_vpc.main.id
  port        = 3306
  cidr_blocks = [aws_vpc.main.cidr_block]
}

# ===============================================
# ElastiCache
# ===============================================
# 1. ElasticCacheパラメータグループ
resource "aws_elasticache_parameter_group" "tfdock-ec" {
  name   = "tfdock-ec"
  family = "redis5.0"

  parameter {
    name  = "cluster-enabled"
    value = "no"
  }
}