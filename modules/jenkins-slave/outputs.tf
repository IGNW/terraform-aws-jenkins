output "jenkins_slave_name" {
  value = "${aws_instance.ec2_jenkins_slave.key_name}"
}
