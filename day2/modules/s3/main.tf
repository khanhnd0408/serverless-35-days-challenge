resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [aws_s3_bucket_ownership_controls.this]

  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket_notification" "on_upload" {
  bucket = aws_s3_bucket.this.id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
  }
}

resource "aws_s3_object" "this" {
  count  = length(var.python_lib_zip) > 0 ? 1 : 0
  bucket = var.bucket_name
  key    = var.python_lib_title
  source = var.python_lib_zip

  etag = try(filemd5(var.python_lib_zip), "")

  depends_on = [var.upload_object_depend_on]
}
