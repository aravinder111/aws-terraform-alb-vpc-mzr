#!/bin/bash
apt-get update -y
apt-get install -y nginx
ec2metadata | grep 'instance-id' >> /var/www/html/index.html