terraform {
   backend "s3" {
    bucket 								= "workshop-tf-state-isaac"
	encrypt 							= true
    key 								= "workshop-site-state-isaac/terraform.tfstate"
    dynamodb_table 						= "tf-workshop-site-locks"
    region 								= "eu-west-3"
  }
} 

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  
  azs 									= var.azs
  vpc_cidr 								= var.vpc_cidr
  private_subnets 						= var.private_subnets
  public_subnets 						= var.public_subnets
  environment 							= var.environment
}

module "database" {
  source = "./modules/database"
  
  azs 							 		= var.azs
  private_subnet 						= module.vpc.private_subnets[0]
  vpc_id 								= module.vpc.vpc_id
  environment 							= var.environment
  password 								= var.db_password
  username 								= var.db_username
  port 								    = var.db_port
  name 								    = var.db_name
  
  depends_on = [module.vpc]
}

module "alb" {
  source = "./modules/load_balancer"
  
  public_subnets 						= module.vpc.public_subnets
  vpc_id 								= module.vpc.vpc_id
  environment 							= var.environment
  
  depends_on = [module.database]
}
