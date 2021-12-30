# Provision resilient infra using terraform on AWS for hosting an nginx web application with Autoscaling in 2 zones and an Application Load Balancer

This is an example terraform project which deploys nginx web application on AWS infrastructure which is:
- isolated in VPC
- two zones hosting one subnet each
- Load balanced
- Auto scales based on CPU utilization
- EC2 instances accessible by SSH
- security for EC2 instances set to only allow http(80), icmp and ssh(22) traffic
- Load Balancer only accepts http(80) traffic

## Assumptions made

1. I used the CIDR `172.1.0.0/25` for VPC
2. I provided some default values for variables in `0-variables.tf` file
3. I have only AWS Free tier account, so I tested the code with EC2 instance type `t2.micro`
4. I split the VPC CIDR into two subnets, one subnet for one zone.
5. I used Ubuntu 20.04 for provisioning EC2 instances.


## How to run

1. Gather AWS account info and install following prerequisites
    - Terraform v1.1.2
    - create an AWS account
2. Setup `terraform.tfvars` file with appropriate values. It should contain following 6 values:
    - AWS_ACCESS_KEY : Your AWS account access key
    - AWS_SECRET_KEY : Your AWS account secret key
    - AWS_REGION : set AWS region for provisioning infrastructure(Example: "us-east-2")
    - instance_type : set EC2 instance type to be provisioned (Example: "t2.micro")
    - PUBLIC_KEY_PATH : set path to your public rsa key so you can ssh into EC2 instances which are created by terraform (Example: "~/.ssh/mykey.pub")
    - ALLOW_CIDR :  provide a cidr block of Public IPs, these IPs will be given SSH access to EC2 instances (Example: "99.145.210.10/32")
3. Run the following commands to provision infra on AWS, making sure each command executes without any errors
    ```sh
    cd <path/to/this/repo>
    terraform init
    terraform plan
    terraform apply
    ```
4. Output of `terraform apply` will print value for `lb_dns_name`, this is load balancer's DNS url, copy paste and hit it from browser. You will see that instance-id rotates between the two serving nginx EC2 instances.
5. Destroy the above provisioned infrastructure by running `terraform destroy` command.