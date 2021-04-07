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

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

## RDS, Subnet, Security group
output "db_subnet_group" {
  value = [ module.database.db_subnet_group ]
}

output "rds_security_group" {
  value = [ module.database.rds_security_group ]
}

## LoadBalancer, Security group
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

## Key pair, Launch Configuration, Autoscaling group (EC2), Security group
output "admin_key_name" {
  value = module.ec2.admin_key_name
}

output "autoscaling_group_id" {
  value = module.ec2.autoscaling_group_id
}

output "ec2_sg_id" {
  value = module.ec2.ec2_sg_id
}