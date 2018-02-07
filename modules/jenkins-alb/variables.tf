variable "name" {
  description = "Name to be used on resources as prefix"
  default     = ""
}

variable "vpc_id" {
  description = "The ID of the VPC"
  default = ""
}

variable "allowed_inbound_cidr_blocks" {
  description = "Networks to allow to connect to the load balancer"
  type        = "list"
}

variable "http_port" {
  description = "HTTP port to access the application server behind the ALB"
}

variable "jenkins_instance_id" {
  description = "The ID of the Jenkins master instance"
}

variable "subnet_ids" {
  description = "Subnets for the load balancer listener to use"
  type = "list"
}

variable "aws_ssl_certificate_arn" {
  description = "Amazon Resource Name for the certificate to be used on the load balancer for HTTPS"
}

variable "dns_zone" {
  description = "DNS zone in AWS Route53 to use with the ALB"
}

variable "app_dns_name" {
  description = "DNS name within the zone to dynamically point to the ALB"
}
