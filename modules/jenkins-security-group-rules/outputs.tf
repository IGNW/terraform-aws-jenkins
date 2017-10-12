# The Name of the security group to which we should add the Jenkins security group rules
output "security_group_name" {
  value = "${aws_security_group.jenkins_security_group.name}"
}

# The ID of the security group to which we should add the Jenkins security group rules
output "jenkins_security_group_id" {
  value = "${aws_security_group.jenkins_security_group.id}"
}