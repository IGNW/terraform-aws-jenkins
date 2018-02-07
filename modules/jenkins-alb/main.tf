# This module builds an Application Load balancer

data "aws_instance" "jenkins" {
  instance_id = "${var.jenkins_instance_id}"
}

data "aws_subnet_ids" "default" {
  vpc_id = "${var.vpc_id}"
}

# Create the security group to control access to the load balancer
module "lb-security-group" {
  source                      = "../jenkins-alb-security-group"
  name_prefix                 = "${var.name}-sg"
  allowed_inbound_cidr_blocks = "${var.allowed_inbound_cidr_blocks}"
  jenkins_private_ip          = "${data.aws_instance.jenkins.private_ip}"
  vpc_id                      = "${var.vpc_id}"
}

# Create the Application Load Balancer, attached to the given subnets
resource "aws_lb" "alb" {
  name            = "${var.name}-alb"
  security_groups = ["${module.lb-security-group.lb_security_group_id}"]
  subnets         = ["${var.subnet_ids}"]
}

# Create a target group to send traffic to for JIRA
resource "aws_lb_target_group" "alb_tg" {
  name      = "${var.name}-alb-tg"
  port      = "${var.http_port}"
  protocol  = "HTTP"
  vpc_id    = "${var.vpc_id}"
}

# Attach the JIRA EC2 instance to the target group
resource "aws_lb_target_group_attachment" "tg_attach" {
  target_group_arn  = "${aws_lb_target_group.alb_tg.arn}"
  target_id         = "${var.jenkins_instance_id}"
  port              = "${var.http_port}"
}

# Associate the listener resource to the load balancer, and configure SSL
resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.aws_ssl_certificate_arn}"

  "default_action" {
    target_group_arn  = "${aws_lb_target_group.alb_tg.arn}"
    type              = "forward"
  }
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
    name                   = "${aws_lb.alb.dns_name}"
    zone_id                = "${aws_lb.alb.zone_id}"
    evaluate_target_health = false
  }
}