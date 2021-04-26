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

resource "aws_key_pair" "admin_key" {
  key_name 				  = var.environment
  public_key 			  = file("${path.module}/keys/admin.pub")
  
  tags 					  = { Name = "${var.environment}-key_pair" }
}

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

 assume_role_policy = jsonencode({
  Version: "2012-10-17",
  Statement: [
    {
      Action: "sts:AssumeRole",
      Principal: {
        Service: "ec2.amazonaws.com"
       },
        Effect: "Allow",
        Sid: ""
      }
    ]
  })

  tags = { Name = "${var.environment}-role" }
}

resource "aws_iam_role_policy" "role_policy" {
  name = "role_policy"
  role = aws_iam_role.s3_access_role.id
  # AmazonS3ReadOnlyAccess
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
		  {
            Effect: "Allow",
            Action: [
                "s3:Get*",
                "s3:List*"
            ],
            Resource: "*"
		  }
		]
	})
}

resource "aws_iam_instance_profile" "s3_access_role_profile" {
  name = "s3_access_role_profile"
  role = aws_iam_role.s3_access_role.name
}

resource "aws_launch_configuration" "launch_config" {
  name_prefix             = "${var.environment}_launch_config"
  key_name                = aws_key_pair.admin_key.id
  image_id                = var.ami
  instance_type           = var.instance_type
  iam_instance_profile	  = aws_iam_instance_profile.s3_access_role_profile.name
  security_groups      	  = [aws_security_group.ec2_sg.id]
  enable_monitoring       = true
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
  
  default_cooldown = "300"
  health_check_type = "EC2"
  health_check_grace_period = 300

  lifecycle {
    create_before_destroy = true
  }
  
  tag {
    key                   = "Name"
    value                 = "${var.environment}-autoscaling-group"
    propagate_at_launch   = true
  }
}


resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "${var.environment}-autoscaling-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "${var.environment}-cloudwatch-scale-up-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_3XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "20"

  dimensions = {
    #AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
	LoadBalancer  =  var.alb_arn_suffix
  }

  alarm_description = "This metric count the Load Balancer redirected HTTP request and scale up if more then 20 redirected requests"
  alarm_actions     = [aws_autoscaling_policy.scale_up_policy.arn]

  tags = { Name = "${var.environment}-cloudwatch-scale-up-alarm" }
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "${var.environment}-autoscaling-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "${var.environment}-cloudwatch-scale-down-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_3XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"

  dimensions = {
	LoadBalancer  =  var.alb_arn_suffix
  }

  alarm_description = "This metric count the Load Balancer redirected HTTP request and scale down if less then 10 redirected requests"
  alarm_actions     = [aws_autoscaling_policy.scale_down_policy.arn]
  
  tags = { Name = "${var.environment}-cloudwatch-scale-down-alarm" }
}

resource "aws_autoscaling_policy" "scale_dynamic_CPU_policy" {
  name                   = "${var.environment}-autoscaling-dynamic-CPU-policy"
  policy_type = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name 
  estimated_instance_warmup = 200
  
  # ... other configuration ...
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}