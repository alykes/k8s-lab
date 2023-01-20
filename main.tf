data "external" "wfh_public_ip" {
  program = ["cmd", "/C", "curl -s https://ipinfo.io/json --ssl-no-revoke"]
}

resource "aws_instance" "k8s-lab" {
  ami             = "ami-0c635ee4f691a2310"
  instance_type   = lookup(var.ec2_type, terraform.workspace, "t3a.nano")
  key_name        = "kp-ango-k8s-lab"
  security_groups = [aws_security_group.allow_ssh.name]

  provisioner "remote-exec" {

    inline = [
      "curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"",
      "echo ----- \"$(<kubectl.sha256)  kubectl\" | sha256sum --check",
      "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl",
      "rm ~/kubectl",
      "sudo yum install conntrack docker -y",
      "echo ----- Adding $USER to the docker group",
      "sudo usermod -aG docker $USER",
      "echo ----- User is in the following groups:",
      #"exec sudo su -l $USER",
      "id",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64",
      "sudo install minikube /usr/local/bin/minikube",
      "rm ~/minikube",
      "minikube config set driver docker",
      "echo ----- minikube scheduled to start in 60 seconds",
      "echo \"/usr/local/bin/minikube start --network-plugin=cni --cni=calico\" | at now + 1 minute", #adding delay...because of usermod above
      "echo ----- Adding kubectl completion to bashrc in 120 seconds",
      "echo \"echo 'source <(kubectl completion bash)' >>~/.bashrc\" | at now + 2 minute"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("../.keys/cka-keys/kp-ango-k8s-lab.pem")
    }

    on_failure = continue
  }


  tags = {
    Name = "${terraform.workspace}-ec2"
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