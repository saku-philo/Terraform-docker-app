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