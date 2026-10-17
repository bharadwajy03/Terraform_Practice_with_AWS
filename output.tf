# ============================================================
# VPC OUTPUT
# ============================================================

output "vpc_id" {
  description = "ID of the Demo VPC"
  value       = aws_vpc.bharadwaj-VPC.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}


# ============================================================
# PUBLIC SUBNET OUTPUT
# ============================================================

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}


# ============================================================
# PRIVATE SUBNET OUTPUT
# ============================================================

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}


# ============================================================
# EC2 PUBLIC IP
# ============================================================

output "web_server_public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web_server.public_ip
}


# ============================================================
# S3 BUCKET
# ============================================================

output "s3_bucket_name" {
  description = "Name of the demo S3 bucket"
  value       = aws_s3_bucket.demo_bucket.bucket
}