# Define the load balancer DNS name as an output variable.
output "lb_dns_name" {
  value = aws_lb.demo-alb.dns_name
}