output "security_group_name" {
  value = "${aws_security_group.jenkins_security_group.name}"
}

output "security_group_id" {
  value = "${aws_security_group.jenkins_security_group.id}"
}