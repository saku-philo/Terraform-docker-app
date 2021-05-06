# ===============================================
# ECS
# ===============================================
# 1. ECSクラスタ
resource "aws_ecs_cluster" "web_server" {
  name = "web_server"
}

# 2. タスク定義
resource "aws_ecs_task_definition" "web_server_task" {
  family                   = "web_server"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container_definitions.json")
}

# 3. ECSサービス
# 3-1. ECSサービスの定義
resource "aws_ecs_service" "web_server_service" {
  name                              = "web_server_service"
  cluster                           = aws_ecs_cluster.web_server.arn
  task_definition                   = aws_ecs_task_definition.web_server_task.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.3.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups  = [module.nginx_sg.security_group_id]

    subnets = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = "web_server"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

#　3-2. nginxセキュリティグループモジュール
module "nginx_sg" {
  source      = "./security_group"
  name        = "nginx_sg"
  vpc_id      = aws_vpc.main.id
  port        = 80
  cidr_blocks = [aws_vpc.main.cidr_block]
}

# 4. CloudWatch Logs関係の定義
# 4-1. ロググループ定義
resource "aws_cloudwatch_log_group" "ecs_web_server" {
  name = "/ecs/web_server"
  retention_in_days = 180
}

# 4-2. ECSタスク実行IAMロール
data "aws_ima_policy" "ecs_task_execution_role_policy" {
  # AWS管理ポリシー使用
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
