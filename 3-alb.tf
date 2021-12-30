# Create an application load balancer.
resource "aws_lb" "demo-alb" {
  name               = "demo-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.demovpc-alb-sg.id]
  subnets            = [aws_subnet.demovpc-public-subnet-1.id, aws_subnet.demovpc-public-subnet-2.id]

  tags = {
    Name = "demo-alb"
  }
}

# Create a new target group for the application load balancer.
resource "aws_lb_target_group" "demo-alb-tg" {
  name     = "demo-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demovpc.id

  ##### Alter the destination of the health check.
  # health_check {
  #   healthy_threshold   = 2
  #   unhealthy_threshold = 2
  #   timeout             = 3
  #   target              = "HTTP:80/"
  #   interval            = 30
  # }
}

# create alb listener for http traffic
resource "aws_lb_listener" "demo-alb-listener-http" {
  load_balancer_arn = aws_lb.demo-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo-alb-tg.arn
  }
}