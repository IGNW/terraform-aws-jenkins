provider "aws" {
  region = "${var.aws_region}"
}

data "aws_ami" "jenkins" {
  most_recent      = true

  # If we change the AWS Account in which test are run, update this value.
  owners  = ["312506926764"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "is-public"
    values = ["false"] // flip to public when ready for release
  }

  filter {
    name   = "name"
    values = ["jenkins-amazon-linux-*"]
  }
}

module "jenkins-master" {
  source = "./modules/jenkins-master"

  vpc_id = "${data.aws_vpc.default.id}"

  name  = "${var.name == "" ? "jenkins-master" : join("-", list(var.name, "jenkins-master"))}"
  instance_type = "${var.instance_type_master}"

  ami_id    = "${var.ami_id == "" ? data.aws_ami.jenkins.image_id : var.ami_id}"
  user_data = "${data.template_file.user_data_master.rendered}"

  #subnet_ids = "${data.aws_subnet_ids.default.ids}"

  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
  ssh_key_path                = "${var.ssh_key_path}"
}

data "template_file" "user_data_master" {
  template = "${file("./modules/jenkins-master/setup.tpl")}"
}


/*
module "jenkins-slaves" {
  source = "./modules/jenkins-slave"

  name  = "${var.name}-jenkins-slave"
  instance_type = "${var.instance_type_master}"

  ami_id    = "${var.ami_id == "" ? data.aws_ami.jenkins.image_id : var.ami_id}"
  user_data = "${data.template_file.user_data_master.rendered}"

  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = "${data.aws_subnet_ids.default.ids}"

  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
}
*/

/*
data "template_file" "user_data_slave" {
  template = "${file("${path.module}/examples/root-example/user-data-slave.sh")}"

  vars {
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.cluster_name}"
  }
}
*/

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}