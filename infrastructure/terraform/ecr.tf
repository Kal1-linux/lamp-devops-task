# ---------------------------------------------------------------------------
# AWS Elastic Container Registry (ECR) for Container Images
# Enforces image scanning on push and AES256 server-side encryption.
# ---------------------------------------------------------------------------

resource "aws_ecr_repository" "lamp_web_repo" {
  name                 = "lamp-web-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

output "ecr_repository_url" {
  description = "URL of the AWS ECR Repository for pushing Docker images"
  value       = aws_ecr_repository.lamp_web_repo.repository_url
}
