# ===============================================
# S3
# ===============================================
# 1. private bucket
resource "aws_s3_bucket" "private" {
  bucket = "tf-docker-app-private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket                  = aws_s3_bucket.private.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. public bucket
resource "aws_s3_bucket" "public" {
  bucket = "tf-docker-app-public"
  acl    = "public-read"

  cors_rule {
    allowed_origins = ["https://www.example.com"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}

# 3. log bucket
resource "aws_s3_bucket" "alb_log" {
  bucket = "tf-docker-app-alb-log"

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }

  force_destroy = true
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      type        = "AWS"
      identifiers = ["582318560864"]
    }
  }
}

# 4. Ops server log bucket
resource "aws_s3_bucket" "operation" {
  bucket = "tf-docker-app-operation-log"

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }

  force_destroy = true
}
