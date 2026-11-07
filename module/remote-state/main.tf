# S3 bucket + DynamoDB table that hold Terraform state for one environment.
# The bucket is versioned, encrypted, private and TLS-only, because state can
# contain secrets (e.g. the OpenSearch master password).

resource "aws_s3_bucket" "terraform_state" {
  #checkov:skip=CKV_AWS_18:Access logging needs a second log bucket; CloudTrail data events are the preferred audit trail for a state bucket.
  #checkov:skip=CKV_AWS_144:Cross-region replication is not needed for a staging state bucket; versioning covers accidental overwrite.
  #checkov:skip=CKV2_AWS_62:No consumer for S3 event notifications on the state bucket.
  bucket = local.bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = local.tags
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      # aws:kms without a key id uses the AWS-managed aws/s3 key.
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.terraform_state]
}

# Deny any request that is not over TLS.
data "aws_iam_policy_document" "tls_only" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.tls_only.json

  depends_on = [aws_s3_bucket_public_access_block.terraform_state]
}

# Lock table for the classic S3 backend (dynamodb_table = ...).
# Terraform >= 1.10 can lock with S3 alone (use_lockfile = true); the table is
# kept so older CLIs and existing pipelines still lock correctly.
resource "aws_dynamodb_table" "terraform_state_lock" {
  #checkov:skip=CKV_AWS_119:Lock table holds only lock IDs, no data; the AWS-owned key is sufficient.
  name         = local.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  deletion_protection_enabled = true

  lifecycle {
    prevent_destroy = true
  }

  tags = local.tags
}
