output "instance_id" {
  value = aws_instance.this.id
}


output "public_ip" {
  value = aws_instance.this.public_ip
}


output "private_ip" {
  value = aws_instance.this.private_ip
}


output "network_interface_id" {
  value = aws_instance.this.primary_network_interface_id
}
