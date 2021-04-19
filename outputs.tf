## AWS environment
output "environment" {
  value = var.environment
}

output "region" {
  value = var.region
}

## VPC, Subnets, Eip, Internet Getway, NAT Getway, Route tables
output "vpc_cidr" {
  value = module.vpc.cidr_block
}

## LoadBalancer, Security group
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

## Key pair, Launch Configuration, Autoscaling group (EC2), Security group
output "admin_key_name" {
  value = module.ec2.admin_key_name
}
