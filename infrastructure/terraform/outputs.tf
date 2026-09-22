output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.lamp_web.public_ip
}

output "instance_id" {
  value = aws_instance.lamp_web.id
}

# Writes an Ansible inventory file with the instance's IP so `ansible-playbook`
# can be run immediately after `terraform apply` without manual copy/paste.
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
    [webserver]
    ${aws_instance.lamp_web.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${var.key_name}.pem
  EOT
}
