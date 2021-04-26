## AWS environment
output "environment" {
  value = var.environment
}

output "region" {
  value = var.region
}

## VPC
output "vpc_cidr" {
  value = module.vpc.cidr_block
}

## LoadBalancer DNS address
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

## Key pair name
output "admin_key_name" {
  value = module.ec2.admin_key_name
}
