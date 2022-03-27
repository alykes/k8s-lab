data "external" "wfh_public_ip" {
  program = ["cmd", "/C", "curl -s https://ipinfo.io/json"]
}

resource "aws_instance" "k8s-lab" {
  ami             = "ami-0b7dcd6e6fd797935"
  instance_type   = lookup(var.ec2_type, terraform.workspace, "t3a.nano")
  key_name        = "k8s-lab"
  security_groups = [aws_security_group.allow_ssh.name]

  provisioner "remote-exec" {

    script = "./scripts/setup.sh"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("../../keys/k8s-lab.pem")
    }

    on_failure = continue
  }


  tags = {
    Name = "${terraform.workspace}-k8s-lab-kubeadm"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.external.wfh_public_ip.result.ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}