resource "aws_key_pair" "admin_key" {
  key_name 				  = var.environment
  public_key 			  = file("${path.module}/keys/admin.pub")
  
  tags 					  = { Name = "${var.environment}-key_pair" }
}

resource "aws_launch_configuration" "launch_config" {
  name_prefix             = "${var.environment}_launch_config"
  key_name                = aws_key_pair.admin_key.id
  image_id                = var.ami
  instance_type           = var.instance_type
  security_groups      	  = [aws_security_group.ec2_sg.id]
  enable_monitoring       = false
  user_data 			  = file("${path.module}/templates/project-app.cloudinit")

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "autoscaling_group" {
  name 				      = "${var.environment}_autoscaling_group"
  launch_configuration 	  = aws_launch_configuration.launch_config.id
  min_size             	  = var.autoscaling_group_min_size
  desired_capacity     	  = var.autoscaling_group_desired_capacity
  max_size             	  = var.autoscaling_group_max_size
  target_group_arns       = [var.target_group_arn]
  vpc_zone_identifier     = var.public_subnets[0]

  tag {
    key                   = "Name"
    value                 = "${var.environment}-autoscaling-group"
    propagate_at_launch   = true
  }
}


resource "aws_security_group" "ec2_sg" {
  name        			  = "${var.environment}-ec2_security_group"
  vpc_id      			  = var.vpc_id

  ingress {
    from_port   		  = 22
    to_port     		  = 22
    protocol    		  = "tcp"
    cidr_blocks 	 	  = ["0.0.0.0/0"]
  }

  ingress {
    from_port       	  = 80
    to_port         	  = 80
    protocol        	  = "tcp"
    cidr_blocks 	 	  = ["0.0.0.0/0"]
  }
  
  # Allow outbound internet access.
  egress {
    from_port   		  = 0
    to_port     		  = 0
    protocol    		  = "-1"
    cidr_blocks 	 	  = ["0.0.0.0/0"]
  }

  tags 					  = { Name = "${var.environment}-ec2_security_group" }
}

