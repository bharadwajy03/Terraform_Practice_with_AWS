variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}


variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}


variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}


variable "public_az" {
  description = "Availability Zone for the public subnet"
  type        = string
}


variable "private_az" {
  description = "Availability Zone for the private subnet"
  type        = string
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}


variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}