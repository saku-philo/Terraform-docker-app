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

# 2. ElastiCacheサブネットグループ
resource "aws_elasticache_subnet_group" "tfdock-ec" {
  name = "tfdock-ec"
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

# 3. ElastiCacheレプリケーショングループ
resource "aws_elasticache_replication_group" "tfdock-ec" {
  replication_group_id          = "tfdock-ec"
  replication_group_description = "Cluster Disabled"
  engine                        = "redis"
  engine_version                = "5.0.5"
  number_cache_clusters         = 3
  node_type                     = "cache.m5.large"
  snapshot_window               = "09:10-10:10"
  snapshot_retention_limit      = 7
  maintenance_window            = "mon:10:40-mon:11:40"
  automatic_failover_enabled    = true
  port                          = 6379
  apply_immediately             = false
  security_group_ids            = [module.redis_sg.security_group_id]
  parameter_group_name          = aws_elasticache_parameter_group.tfdock-ec.name
  subnet_group_name             = aws_elasticache_subnet_group.tfdock-ec.name
}

# 4. ElastiCacheセキュリティグループ
module "redis_sg" {
  source      = "./security_group"
  name        = "redis-sg"
  vpc_id      = aws_vpc.main.id
  port        = 6379
  cidr_blocks = [aws_vpc.main.cidr_block]
}
