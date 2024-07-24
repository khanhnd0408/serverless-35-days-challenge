resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = var.trusted_role_service
        }
      },
    ]
  })

  tags = var.role_tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(var.attach_policies_arn)
  role       = aws_iam_role.this.name
  policy_arn = var.attach_policies_arn[count.index]
}
