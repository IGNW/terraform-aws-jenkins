output "security_group_name" {
  value = "${module.security_group_rules.security_group_name}"
}

output "jenkins_security_group_id" {
  value = "${module.security_group_rules.jenkins_security_group_id}"
}

output "private_ip" {
  value = "${aws_instance.ec2_jenkins_master.private_ip}"
}

output "public_ip"  {
  value = "${aws_instance.ec2_jenkins_master.public_ip}"
}