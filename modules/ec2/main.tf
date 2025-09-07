resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  associate_public_ip_address = var.associate_public_ip_address

  vpc_security_group_ids      = var.security_group_ids

  source_dest_check = var.source_dest_check

  tags = {
    Name = var.name
  }
}
