# ===============================================
# CloudWatch Logs
# ===============================================
# 1. IAMロール
# 1-1. ポリシードキュメント
data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    effect    = "Allow"
    actions   = ["firehose:*"]
    resources = ["arn:aws:firehose:ap-northeast-1:*:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::*:role/cloudwatch-logs"]
  }
}

# 1-2. IAMロール
module "cloudwatch_logs_role" {
  source     = "./iam_role"
  name       = "cloudwatch-logs"
  identifier = "logs.ap-northeast-1.amazonaws.com"
  policy     = data.aws_iam_policy_document.cloudwatch_logs.json
}

# 2. CloudWatch Logsサブスクリプションフィルタ
resource "aws_cloudwatch_log_subscription_filter" "tf-dock" {
  name            = "tf-dock"
  log_group_name  = aws_cloudwatch_log_group.ecs_scheduled_tasks.name
  destination_arn = aws_kinesis_firehose_delivery_stream.tf-dock.arn
  filter_pattern  = "[]"
  role_arn        = module.cloudwatch_logs_role.iam_role_arn
}
