# ===============================================
# ECR
# ===============================================
# 1. ECRリポジトリ
resource "aws_ecr_repository" "tf-dock" {
  name = "tf-dock"
}

# 2. ECRライフサイクルポリシー
resource "aws_ecr_lifecycle_policy" "tf-dock" {
  repository = aws_ecr_repository.tf-dock.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 30 release tagged images.",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}
