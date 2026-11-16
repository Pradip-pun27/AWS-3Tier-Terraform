# Fetch the latest official Canonical Ubuntu 24.04 LTS AMI dynamically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch Template for Auto-Scaled PHP Application Servers
resource "aws_launch_template" "php_app" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    db_host     = aws_db_instance.mysql.address
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-app-instance"
      Tier = "Application"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group across the 2 Private App Subnets
resource "aws_autoscaling_group" "php_app" {
  name                      = "${var.project_name}-asg"
  min_size                  = var.asg_min_size
  desired_capacity          = var.asg_desired_capacity
  max_size                  = var.asg_max_size
  vpc_zone_identifier       = aws_subnet.private_app[*].id
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.php_app.id
    version = "$Latest"
  }

  # Ensure NAT Gateway routing is active before EC2 instances boot and run apt-get
  depends_on = [
    aws_nat_gateway.nat,
    aws_route_table_association.private_app
  ]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-node"
    propagate_at_launch = true
  }
}

# Automatic CPU Target Tracking Scaling Policy (Scales out at > 50% CPU)
resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${var.project_name}-cpu-target-policy"
  autoscaling_group_name = aws_autoscaling_group.php_app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}