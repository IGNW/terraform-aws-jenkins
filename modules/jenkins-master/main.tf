# Launch EC2 instance for master

resource "aws_instance" "ec2_jenkins_master" {
  count                  = 1
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  user_data              = "${var.user_data}"
  key_name               = "${var.ssh_key_name}"
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.jenkins_security_group.id}"]
  tags = "${merge(map("Name", format("%s-%d", var.name, count.index+1)), map("Terraform", "true"), map("Environment", var.environment), var.tags)}"

  provisioner "file" {
    connection  = {
      user = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }
    content     = "${data.template_file.plugins.rendered}"
    destination = "/tmp/plugins.sh"
  }

  provisioner "remote-exec" {
    connection  = {
      user = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }
    inline = [
      "chmod +x /tmp/plugins.sh",
      "sudo /tmp/plugins.sh"
    ]
  }
}

data "template_file" "plugins" {
  template = "${file("./modules/jenkins-master/plugins.tpl")}"

  vars {
    plugins = "${var.plugins}"
  }

}

# create security group to allow ssh
resource "aws_security_group" "jenkins_security_group" {
  name_prefix = "${var.name}"
  description = "Security group for the ${var.name}"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type        = "ingress"
  from_port   = "${var.ssh_port}"
  to_port     = "${var.ssh_port}"
  protocol    = "tcp"
  cidr_blocks = ["${var.allowed_ssh_cidr_blocks}"]

  security_group_id = "${aws_security_group.jenkins_security_group.id}"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.jenkins_security_group.id}"
}

module "security_group_rules" {
  source = "../jenkins-security-group-rules"

  security_group_id           = "${aws_security_group.jenkins_security_group.id}"
  allowed_inbound_cidr_blocks = ["${var.allowed_inbound_cidr_blocks}"]

  http_port = "${var.http_port}"
  https_port = "${var.https_port}"
  jnlp_port = "${var.jnlp_port}"
}