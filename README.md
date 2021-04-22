# Terraform-docker-app

## システム要件
- 可用性、スケーラビリティ、セキュリティを可能な範囲で考慮
- マネージドサービスを積極的に採用

## アーキテクチャ
- HTTPSでサービスにアクセス
- ALB -> public subnetに配置
- コンテナオーケストレーションサービス、DB -> private subnetに配置
- 鍵管理はマネージドサービスを使用

## 使用テクノロジー
- 権限管理: IAMポリシー、IAMロール
- ストレージ: S3
- ネットワーク: VPC, NAT Gateway, Security Group
- ELB, DNS: ALB, Route53, ACM
- コンテナオーケストレーション: ECS Fargate
- バッチ: ECS Scheduled Tasks
- 鍵管理: KMS
- 設定管理: SSMパラメータストア
- データストア: RDS, ElastiCache
- デプロイパイプライン: ECR, CodeBuild, CodePipeline
- SSHレスオペレーション: EC2, Session Maneger
- ロギング: CloudWatch Logs, Kinesis Data Firehose

## ファイルレイアウト
```
project directory/
├ some_module/
│   └ some.tf
└ main.tf/
```