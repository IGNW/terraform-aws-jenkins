#-------------------
# LB security group
#-------------------
resource "aws_security_group" "lb_security_group" {
  name_prefix = "${var.name_prefix}-lb"
  description = "Security group for the load balancer"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${var.name_prefix}-lb"
  }
}

# Allow HTTPS in from specific external subnets if public access is not enabled
resource "aws_security_group_rule" "allow_lb_https_inbound" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["${var.jenkins_private_ip}/32", "${var.allowed_inbound_cidr_blocks}"]

  security_group_id = "${aws_security_group.lb_security_group.id}"
}

resource "aws_security_group_rule" "allow_lb_outbound" {
  type = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.lb_security_group.id}"
}
