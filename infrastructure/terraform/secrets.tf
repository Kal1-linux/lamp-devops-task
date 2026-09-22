# ---------------------------------------------------------------------------
# AWS Secrets Manager Integration for Database Credentials
# Ensures no sensitive passwords are hardcoded in code or committed to Git.
# ---------------------------------------------------------------------------

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "lamp_db_secret" {
  name                    = "lamp-stack/db-credentials"
  description             = "Database credentials for LAMP stack application"
  recovery_window_in_days = 0

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "lamp_db_secret_version" {
  secret_id = aws_secretsmanager_secret.lamp_db_secret.id
  secret_string = jsonencode({
    db_name             = var.db_name
    db_user             = var.db_user
    db_password         = random_password.db_password.result
    mysql_root_password = random_password.db_password.result
  })
}

# IAM policy allowing EC2 instance to retrieve database secret from Secrets Manager
resource "aws_iam_policy" "secretsmanager_read_policy" {
  name        = "lamp-ec2-secretsmanager-read"
  description = "Allows EC2 instance to read database secrets from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.lamp_db_secret.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.lamp_ec2_role.name
  policy_arn = aws_iam_policy.secretsmanager_read_policy.arn
}
