variable "name" {
  description = "Name to be used for the Jenkins master instance"
}

variable "jenkins_master_ip" {
  description = "The IP of the master jenkins instance"
}

variable "jenkins_master_port" {
  description = "The Port of the master jenkins instance"
}

variable "environment" {
  description = "The environement tag to add to Jenkins master instance",
  default     = ""
}

variable "ami_id" {
  description = "The ID of the AMI to run in this Jenkins slave instance"
}

variable "instance_type" {
  description = "Instance Type to use for Jenkins master"
}

variable "count" {
  description = "The number of slave instance(s) to create"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "ssh_key_path" {
  description = "The path of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Used for provisioning."
  default     = ""
}

variable "jenkins_security_group_id" {
  description = "The jenkins security group to assign to this instance."
  default     = ""
}

variable "tags" {
  type = "map"
  description = "Supply tags you want added to all resources"
  default = {
  }
}