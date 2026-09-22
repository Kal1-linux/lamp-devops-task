# Production Remote State Configuration with AWS S3 and DynamoDB State Locking
terraform {
  required_version = ">= 1.5"
  backend "s3" {
    bucket         = "lamp-stack-production-tfstate"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "lamp-stack-tfstate-locks"
  }
}
