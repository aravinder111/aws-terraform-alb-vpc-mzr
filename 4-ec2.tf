# Create a key pair that will be used to ssh into ec2 instances.
resource "aws_key_pair" "mykey" {
  key_name = "mykey"
  public_key = file(var.PUBLIC_KEY_PATH)
}

# Create a new EC2 launch configuration to be used with the autoscaling group.
resource "aws_launch_configuration" "demo-launch-config" {
  name                        = "demo-instance"
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.mykey.key_name
  security_groups             = [aws_security_group.demovpc-ec2-sg.id]
  associate_public_ip_address = true
  user_data                   = file("nginx_script.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# Create the autoscaling group.
resource "aws_autoscaling_group" "demo-autoscaling-group" {
  name                 = "demo-autoscaling-group"
  launch_configuration = aws_launch_configuration.demo-launch-config.name
  min_size             = 2
  max_size             = 4
  target_group_arns    = [aws_lb_target_group.demo-alb-tg.arn]
  vpc_zone_identifier  = [aws_subnet.demovpc-public-subnet-1.id, aws_subnet.demovpc-public-subnet-2.id]
  force_delete = true

  tag {
    key                 = "Name"
    value               = "demo-autoscaling-group"
    propagate_at_launch = true
  }
}

# Set below scale up policy along with cloud watch metric alarm
resource "aws_autoscaling_policy" "demo-autoscaling-cpu-policy" {
  name                   = "demo-autoscaling-cpu-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.demo-autoscaling-group.name
}
resource "aws_cloudwatch_metric_alarm" "demo-autoscaling-cpu-alarm" {
  alarm_name          = "demo-autoscaling-cpu-alarm"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.demo-autoscaling-group.name
  }
  actions_enabled   = true
  alarm_actions     = [aws_autoscaling_policy.demo-autoscaling-cpu-policy.arn]
}

# Set below scale down policy along with cloud watch metric alarm
resource "aws_autoscaling_policy" "demo-descaling-cpu-policy" {
  name                   = "demo-descaling-cpu-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 45
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.demo-autoscaling-group.name
}
resource "aws_cloudwatch_metric_alarm" "demo-descaling-cpu-alarm" {
  alarm_name          = "demo-descaling-cpu-alarm"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "15"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.demo-autoscaling-group.name
  }
  actions_enabled   = true
  alarm_actions     = [aws_autoscaling_policy.demo-descaling-cpu-policy.arn]
}