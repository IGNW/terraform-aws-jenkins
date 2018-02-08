variable "vpc_id" {
  description = "The ID of the VPC"
  default = ""
}

variable "name_prefix" {
  description = "The prefix for the load balancer instance name"
}

variable "allowed_inbound_cidr_blocks" {
  description = "Networks to allow to connect to Jenkins"
  type        = "list"
}

variable "jenkins_private_ip" {
  description = "Private IP address of the Jenkins instance"
}
