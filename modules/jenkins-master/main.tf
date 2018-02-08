# Launch EC2 instance for master

// TODO: Add ELB for HTTP & HTTPS
// TODO: Lockdown traffic and make instances private
// TODO: Refactor security group code so Master has SSH, HTTP + JNLP and Slaves only have SSH, JNLP

# Master ELB
/*
resource "aws_iam_server_certificate" "test_cert" {
  name_prefix      = "example-cert"
  certificate_body = "${file("self-ca-cert.pem")}"
  private_key      = "${file("test-key.pem")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "ourapp" {
  name                      = "terraform-asg-deployment-example"
  availability_zones        = ["us-west-2a"]
  cross_zone_load_balancing = true

  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${aws_iam_server_certificate.test_cert.arn}"
  }

  # The instances are registered automatically
  instances = ["${aws_instance.web.*.id}"]
}

*/

# Master Server
resource "aws_instance" "ec2_jenkins_master" {
  count                  = 1
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  user_data              = "${var.user_data}"
  key_name               = "${var.ssh_key_name}"
  monitoring             = true
  vpc_security_group_ids = ["${module.security_group_rules.jenkins_security_group_id}"]
  tags = "${merge(map("Name", format("%s-%d", var.name, count.index+1)), map("Terraform", "true"), map("Environment", var.environment), var.tags)}"

  provisioner "file" {
    connection  = {
      user = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }
    content     = "${var.setup_data}"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    connection  = {
      user = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh"
    ]
  }
}

module "security_group_rules" {
  source = "../jenkins-security-group-rules"

  name      = "${var.name}"
  allowed_inbound_cidr_blocks = ["${var.allowed_inbound_cidr_blocks}"]
  allowed_ssh_cidr_blocks = ["${var.allowed_ssh_cidr_blocks}"]

  http_port = "${var.http_port}"
  https_port = "${var.https_port}"
  jnlp_port = "${var.jnlp_port}"
}

# Add the application load balancer
module "jenkins-alb" {
  source                      = "../jenkins-alb"
  name_prefix                 = "${var.alb_prefix}"
  vpc_id                      = "${var.vpc_id}"
  allowed_inbound_cidr_blocks = "${var.allowed_inbound_cidr_blocks}"
  http_port                   = "${var.http_port}"
  jenkins_instance_id         = "${aws_instance.ec2_jenkins_master.id}"
  subnet_ids                  = "${var.subnet_ids}"
  aws_ssl_certificate_arn     = "${var.aws_ssl_certificate_arn}"
  app_dns_name                = "${var.app_dns_name}"
  dns_zone                    = "${var.dns_zone}"
}
