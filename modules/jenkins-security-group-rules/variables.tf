variable "security_group_id" {
  description = "The ID of the security group to which we should add the Jenkins security group rules"
}

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Jenkins"
  type        = "list"
}

variable "http_port" {
  description = "The port to use for HTTP traffic to Jenkins"
  default     = 8080
}

variable "https_port" {
  description = "The port to use for HTTPS traffic to Jenkins"
  default     = 443
}

variable "jnlp_port" {
  description = "The port to use for TCP traffic between Jenkins intances"
  default     = 49187
}