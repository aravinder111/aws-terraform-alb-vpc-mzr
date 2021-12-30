# security group for vpc ec2 instances to allow ssh, ping and http traffic.
resource "aws_security_group" "demovpc-ec2-sg" {
  name        = "demovpc-ec2-sg"
  vpc_id      = aws_vpc.demovpc.id

  # Restrict inboud SSH traffic by IP address.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ALLOW_CIDR]
  }

  # Allow ICMP echo requests.
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [var.ALLOW_CIDR]
  }

  # Restrict inbound HTTP traffic only from the load balancer.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.demovpc-alb-sg.id]
  }

  # Allow outbound internet access.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demovpc-ec2-sg"
  }
  depends_on = [aws_security_group.demovpc-alb-sg]
}

# application load balancer security group.
resource "aws_security_group" "demovpc-alb-sg" {
  name        = "demovpc-alb-sg"
  vpc_id      = aws_vpc.demovpc.id

  # allow only http traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.ALLOW_CIDR]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demovpc-alb-sg"
  }
}