variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  default = "us-east-2"
}

variable "PUBLIC_KEY_PATH" {
  default= "mykey.pub"
}

variable "ALLOW_CIDR" {
  default = "99.145.206.221/32"
}

variable "instance_type" {
  default = "t2.micro"
}