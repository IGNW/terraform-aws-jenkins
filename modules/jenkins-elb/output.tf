output "lb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}
