variable "name" {
  description = "Name to be used on all resources as prefix"
  default     = ""
}

//TODO: add support for muliple masters with active -> passive failover
/*
variable "master_count" {
  description = "Number of master instances to launch"
  default     = 1
}
*/

variable "slave_count" {
  description = "Number of slave instances to launch"
  default     = 1
}

variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
  default     = "us-east-1"
}

variable "ami_id" {
  description = "ID of AMI to use for instance(s)"
  default     = ""
}

variable "instance_type_master" {
  description = "Instance Type to use for master instance(s)"
  default     = "t2.micro"
}

variable "instance_type_slave" {
  description = "Instance Type to use for slave instance(s)"
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "ssh_key_path" {
  description = "The path of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Used for provisioning."
  default     = ""
}

//TODO: Change to list variable and join in template
variable "plugins" {
  description = "The Jenkins default plugins to install."
  default     = "git xunit"
}

variable "tags" {
  type = "map"
  description = "Supply tags you want added to all resources"
  default = {
  }
}