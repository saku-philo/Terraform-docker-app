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
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
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
  name              = "/ecs/web_server"
  retention_in_days = 180
}

# 4-2. ECSタスク実行IAMロール
# 4-2-1. IAMポリシーデータソース
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  # AWS管理ポリシー使用
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 4-2-2. ポリシードキュメント
data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

# 4-2-3. IAMロール
module "ecs_task_execution_role" {
  source     = "./iam_role"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

# 5. バッチ処理
# 5-1. バッチ用CloudWatch Logs設定
resource "aws_cloudwatch_log_group" "ecs_scheduled_tasks" {
  name              = "/ecs/scheduled_tasks"
  retention_in_days = 180
}

# 5-2. バッチ用タスク定義
resource "aws_ecs_task_definition" "time_batch" {
  family                   = "time_batch"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./batch_container_definitions.json")
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

# 5-3. CloudWatchイベント用IAMロールの定義
module "ecs_events_role" {
  source     = "./iam_role"
  name       = "ecs-events"
  identifier = "events.amazonaws.com"
  policy     = data.aws_iam_policy.ecs_events_role_policy.policy
}

data "aws_iam_policy" "ecs_events_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}
