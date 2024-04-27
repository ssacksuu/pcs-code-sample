provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "dev_s3" {
  bucket_prefix = "dev-"

  tags = {
    Environment      = "Dev"
  }
}


resource "aws_s3_bucket_versioning" "dev_s3" {
  bucket = aws_s3_bucket.dev_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "dev_s3_destination" {
  # checkov:skip=CKV_AWS_144:the resource is auto generated to be a destination for replication
  bucket = aws_s3_bucket.dev_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "dev_s3_replication" {
  name = "aws-iam-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_replication_configuration" "dev_s3" {
  depends_on = [aws_s3_bucket_versioning.dev_s3]
  role   = aws_iam_role.dev_s3_replication.arn
  bucket = aws_s3_bucket.dev_s3.id
  rule {
    id = "foobar"
    status = "Enabled"
    destination {
      bucket        = aws_s3_bucket.dev_s3_destination.arn
      storage_class = "STANDARD"
    }
  }
}



resource "aws_s3_bucket_versioning" "dev_s3" {
  bucket = aws_s3_bucket.dev_s3.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "dev_s3_log_bucket" {
  bucket = "dev_s3-log-bucket"
}

resource "aws_s3_bucket_logging" "dev_s3" {
  bucket = aws_s3_bucket.dev_s3.id

  target_bucket = aws_s3_bucket.dev_s3_log_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dev_s3" {
  bucket = aws_s3_bucket.dev_s3.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}