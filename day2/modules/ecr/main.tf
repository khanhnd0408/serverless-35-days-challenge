resource "aws_ecr_repository" "private_repository" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.tags
}

resource "aws_ecr_repository_policy" "policy" {
  repository = aws_ecr_repository.private_repository.name

  policy = var.policy
}
