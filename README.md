# Terraform Infrastructure Provisioning
This repo creates "environment" modules with all the necessary resources to enable end-to-end interaction with a Web-app and RDS on AWS


## What are we provisioning here?
- VPC and Gateway resources
- Security groups
- Subnets
- RDS
- Load-Balancer
- Autoscaling Group
- LaunchConfiguration including a user-data script
- IAM Role


## Prerequisite resources
- AWS cli configure
- AWS bucket with a folder holding the terraform statefile
- Dynamodb table use for lock file
- An admin RSA public key (for SSH connection to the instances)
- Create IAM role with S3 Access
- S3 Bucket with a tar file of your application


## Persistence
- The terraform statefile is stored in an AWS S3 bucket
- The terraform lock file is stored in AWS Dynamodb


## Requirements

### Network Requirements:
- The inter-domain address range should be: 16382
- The address range should be equally distributed between the public-subnets and the private-subnets

### Instances Requirements:
- Use free-tier instances only (t2.micro)
- All resources will use public subnets, to allow traffic from outside
- The instances should allow incoming traffic on port 80 from the LB only
- The instances should allow SSH access to the admin user
- Each DB subnet group must have at least two Availability Zones in the Region so we have 2 private subnets for RDS
- You can specify only one subnet per Availability Zone. You must specify subnets from at least two Availability Zones so we have 2 public subnets for RDS

### RDS Requirements:
- Use free-tier instances only (t2.micro)
- All resources will use private subnets, to allow traffic only from the instances in the VPC
- Each DB subnet-group must have at least two Availability Zones in the Region so we have 2 private subnets for RDS


## Setup and Adjustments

### Setup
You can basically run  ```terraform init```  to initialize the modules
run  ```terraform plan```  for a dry-run 
and  ```terraform apply```  this will execute the code and setup the environment in the AWS region "eu-west-3"

### A little more advanced setup
Now suppose we want to provision the same environment for our development, testing and production but our customers are in the US and the development and testing teams are in Europe
So we can simply run the command  ```terraform apply -var-file=./prod/prod.tfvars```  and this will setup the exact same environment according to the variables in that file,
for example setup the prod environment in "us-east-1" region in the US for our customers
(the difference can be instances types or scale)

### EC2 Adjustments

#### Keys
Every instance needs a key and the public key here is the file 'modules\ec2\keysadmin.pub' and you can change it according to your generated key so you can ssh to the instances using you private key

#### Script
All instances runs the script at startup, you can find it in 'modules\ec2\templates\project-app.cloudinit', 
the script installs git and chef-solo and then run my cookbook from my repo https://github.com/isaacTadela/chef_cookbook
and you can customize it too to your needs

#### EC2 Role - S3 Access
I assume that your application residing in an s3 bucket as a tar file 
So every ec2 instance have a role attached to it with access of AmazonS3ReadOnlyAccess policy that you can also customize to your needs


## Done
Do not forget to terminate the instances, time is money
```terraform destroy```


## Diagram
Seeing is believing or understanding so for the finally you can see here a 3D diagram of all the environment
(generated with Cloudcraft)

![cloudcraft diagram]( /cloudcraft%20diagram(3D).png )
