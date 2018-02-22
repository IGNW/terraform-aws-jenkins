# This module builds an Application Load balancer

data "aws_instance" "jenkins" {
  instance_id = "${var.jenkins_instance_id}"
}

data "aws_subnet_ids" "default" {
  vpc_id = "${var.vpc_id}"
}

resource "aws_elb" "elb" {
  name                = "${var.name_prefix}-elb"
  availability_zones  = ["${var.availability_zone}"]

  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = "${var.https_port}"
    lb_protocol        = "https"
    ssl_certificate_id = "${var.aws_ssl_certificate_arn}"
  }

  listener {
    instance_port     = "${var.jnlp_port}"
    instance_protocol = "tcp"
    lb_port           = "${var.jnlp_port}"
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/login"
    interval            = 30
  }

  instances = ["${var.jenkins_instance_id}"]
}


# Update the DNS zone in AWS Route53 to point our domain name to this ALB
data "aws_route53_zone" "app_dns_zone" {
  name = "${var.dns_zone}"
  private_zone = false
}

resource "aws_route53_record" "dns" {
  zone_id = "${data.aws_route53_zone.app_dns_zone.zone_id}"
  name    = "${var.app_dns_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.elb.dns_name}"
    zone_id                = "${aws_elb.elb.zone_id}"
    evaluate_target_health = false
  }
}