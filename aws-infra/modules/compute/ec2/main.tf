resource "aws_launch_template" "web" {
  name_prefix   = "GenAI-Web"
  description   = "Launch template for GenAI web servers"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = element(var.private_subnet_ids, 0)
    security_groups             = [var.security_group_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "GenAI-Web"
    }
  }
}

resource "aws_autoscaling_group" "GenAI-Web_asg" {
  desired_capacity     = 1
  max_size             = 5
  min_size             = 1
  vpc_zone_identifier  = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "GenAI-Web-asg"
    propagate_at_launch = true
  }

  health_check_type = "EC2"
}
resource "aws_lb" "app" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids

  access_logs {
    bucket  = module.logs_bucket.bucket_name
    prefix  = "alb-logs"
    enabled = true
  }
}
