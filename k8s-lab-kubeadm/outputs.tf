output "security_group_name" {
  value = aws_security_group.allow_ssh.name
}

output "instance_ip" {
  value = aws_instance.k8s-lab.public_ip
}

output "wfh_public_ip" {
  value = data.external.wfh_public_ip.result.ip
}