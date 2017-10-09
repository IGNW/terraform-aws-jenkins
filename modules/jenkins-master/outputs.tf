output "security_group_name" {
  value = "${aws_security_group.jenkins_security_group.name}"
}

output "jenkins_security_group_id" {
  value = "${aws_security_group.jenkins_security_group.id}"
}

output "private_ip" {
  value = "${aws_instance.ec2_jenkins_master.private_ip}"
}

output "public_ip"  {
  value = "${aws_instance.ec2_jenkins_master.public_ip}"
}