variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair, used for SSH access"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH into the instance (restrict this to your own IP in production)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "db_name" {
  description = "Name of the MySQL application database"
  type        = string
  default     = "appdb"
}

variable "db_user" {
  description = "Name of the MySQL application user"
  type        = string
  default     = "appuser"
}
