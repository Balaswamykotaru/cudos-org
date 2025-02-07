resource "aws_s3_bucket" "terraform_state_cudos_5" {
  bucket = "terraform-state-cudos-5"
}
  
resource "aws_s3_bucket_versioning" "versioning" {
    bucket = aws_s3_bucket.terraform_state_cudos_5.id
 versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mykey_5" {
    bucket = aws_s3_bucket.terraform_state_cudos_5.id

  rule {
    apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "access_5" {
  bucket = aws_s3_bucket.terraform_state_cudos_5.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_cudos_5" {
  name         = "terraform-cudos-5"
  hash_key     = "LockID"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  read_capacity = 20
  write_capacity = 20

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
    kms_key_arn = aws_kms_key.dynamodb_encryption_key_cudos_5.arn
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_kms_key" "dynamodb_encryption_key_cudos_5" {
  description             = "DynamoDB Encryption Key"
  enable_key_rotation    = true
}

resource "aws_kms_alias" "dynamodb_encryption_key_cudos_5" {
  name          = "alias/dynamodb_encryption_key_cudos_5"
  target_key_id = aws_kms_key.dynamodb_encryption_key_cudos_5.key_id
}


