
locals {
  jenkins_master_url = "http://${var.jenkins_master_ip}:${var.jenkins_master_port}"
}

data "aws_ami" "jenkins_linux_slave" {
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
    values = ["jenkins-slave-amazon-linux-*"]
  }
}

# Jenkins Slaves
resource "aws_instance" "ec2_jenkins_slave" {
  count                  =  "${var.count}"
  ami                    = "${var.ami_id == "" ? data.aws_ami.jenkins_linux_slave.image_id : var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.ssh_key_name}"
  monitoring             = true
  vpc_security_group_ids = ["${var.jenkins_security_group_id}"]
  tags = "${merge(map("Name", format("%s-%d", var.name, count.index+1)), map("Terraform", "true"), map("Environment", var.environment), var.tags)}"

  provisioner "file" {
    connection  = {
      user = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }
    content     = "${file(var.ssh_key_path)}"
    destination = "/tmp/key.pem"
  }

  # Download dependencies from Master
  provisioner "remote-exec" {
    connection  = {
      user = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }

    inline = [
      "chmod 0600 /tmp/key.pem",
      "ssh -oStrictHostKeyChecking=no -i /tmp/key.pem ec2-user@${var.jenkins_master_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' > /tmp/secret",
      "wget -P /tmp ${local.jenkins_master_url}/jnlpJars/jenkins-cli.jar",
      "wget -P /tmp ${local.jenkins_master_url}/jnlpJars/slave.jar",
      "sudo mv /tmp/slave.jar /home/jenkins/jenkins-slave/"
    ]
  }

  provisioner "file" {
    connection  = {
      user = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }
    content     = "${data.template_file.bootstrap.rendered}"
    destination = "/tmp/bootstrap.sh"
  }

  # Register & Launch slave
  provisioner "remote-exec" {
    connection  = {
      user = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }

    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "/tmp/bootstrap.sh ${self.tags["Name"]}"
    ]
  }

  # Cleanup node registration
  # Currenlty unable to clean-up Jenkins node meta due to TF issue: https://github.com/hashicorp/terraform/issues/13549
  /*
  provisioner "remote-exec" {
    when = "destroy"

    connection  = {
      host = "${self.private_ip}"
      user = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }

    inline = [
      "sudo service jenkins-slave stop",
      "sudo java -jar /tmp/jenkins-cli.jar -auth admin:$(</tmp/secret) -s ${local.jenkins_master_url} delete-node ${self.tags["Name"]}"
    ]
  }
  */
}

data "template_file" "bootstrap" {
  template = "${file("./modules/jenkins-slave/setup.tpl")}"

  vars {
    jenkins_master_url = "${local.jenkins_master_url}"
    jenkins_master_ip = "${var.jenkins_master_ip}"
  }

}