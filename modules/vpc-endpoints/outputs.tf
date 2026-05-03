# -----------------------------------------------
# ENDPOINT IDS
# Useful for referencing in security group rules
# -----------------------------------------------
output "s3_endpoint_id" {
  description = "ID of the S3 gateway endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "ecr_api_endpoint_id" {
  description = "ID of the ECR API interface endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_endpoint_id" {
  description = "ID of the ECR DKR interface endpoint"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "eks_endpoint_id" {
  description = "ID of the EKS interface endpoint"
  value       = aws_vpc_endpoint.eks.id
}

output "sts_endpoint_id" {
  description = "ID of the STS interface endpoint"
  value       = aws_vpc_endpoint.sts.id
}

output "ec2_endpoint_id" {
  description = "ID of the EC2 interface endpoint"
  value       = aws_vpc_endpoint.ec2.id
}

output "security_group_id" {
  description = "ID of the VPC endpoints security group"
  value       = aws_security_group.vpc_endpoints.id
}