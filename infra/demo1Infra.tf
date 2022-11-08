terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "~> 4.16.0"
		}
	}
}
	
provider "aws" {
	profile = "default"
	region  = "us-east-1"
}          

module "vpc" {
	source  = "terraform-aws-modules/vpc/aws"
	version = "3.14.0"
	name = "demo1-VPC"     #111111111
	cidr = "10.0.0.0/23"
	azs = ["us-east-1a","us-east-1b"]
	public_subnets = ["10.0.0.0/24","10.0.1.0/24"]
}

module "key-pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "1.0.1"
  key_name = "demo1-key"    #1111111111
  public_key = file("${path.module}/taskApprentice.pub")
} 

module "sg-public" {
	source  = "terraform-aws-modules/security-group/aws"
	version = "4.9.0"
	name = "demo1-sg-public"
	description = "Public security group"
	vpc_id = module.vpc.vpc_id 
	egress_rules = ["all-all"]
	ingress_with_cidr_blocks = [
		{
			from_port = 22
			to_port = 22
			protocol = "tcp"
			description = "SSH service"
			cidr_blocks = "0.0.0.0/0"
		}, 
		{
			from_port = 80
			to_port = 80
			protocol = "tcp"
			description = "HTTP service"
			cidr_blocks = "0.0.0.0/0" 
		},

	]
	
}

module "ec2-front-1" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    version = "4.0.0"
    name = "demo1-front01-ec2"
    ami = "ami-052efd3df9dad4825" 
    instance_type = "t2.micro"
    key_name = module.key-pair.key_pair_key_name  
    vpc_security_group_ids = [module.sg-public.security_group_id]
    subnet_id = module.vpc.public_subnets[0]
    availability_zone = module.vpc.azs[0]
    associate_public_ip_address = true  
}

module "ec2-front-2" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    version = "4.0.0"
    name = "demo1-front02-ec2"
    ami = "ami-052efd3df9dad4825" 
    instance_type = "t2.micro"
    key_name = module.key-pair.key_pair_key_name  
    vpc_security_group_ids = [module.sg-public.security_group_id]
    subnet_id = module.vpc.public_subnets[1]
    availability_zone = module.vpc.azs[1]
    associate_public_ip_address = true  
}

module "alb_http" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "demo1-alb"
  
  load_balancer_type = "application"
  
  vpc_id  = module.vpc.vpc_id
  subnets         = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  # security_groups = [module.sg-public.security_group_id]
  
  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
          ec2front1_target = {
             target_id = module.ec2-front-1.id
             port = 80
          }
          ec2front2target = {
             target_id = module.ec2-front-2.id
             port = 80
          }
      }
    }
  ]
  
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

}

output "ec2-front1-pub-ip" {
  value = module.ec2-front-1.public_ip
}

output "ec2-front2-pub-ip" {
  value = module.ec2-front-2.public_ip
}