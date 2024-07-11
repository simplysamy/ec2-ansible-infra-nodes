
resource "aws_default_vpc" "default" {}

resource "aws_instance" "my_instances" {
  for_each               = var.instances
  ami                    = var.ami
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.ansible_node_sg.id]
  key_name               = var.key_name
  user_data              = <<-EOF
                #!/bin/bash 
                sudo apt update
                chmod 700 ~/.ssh
                chmod 600 ~/.ssh/authorized_keys
                EOF

  tags = {
    Name  = "my-instance-${each.key}"
    "Tag" = each.value
  }
}

resource "aws_security_group" "ansible_node_sg" {
  name_prefix = "instance_sg"
  description = "Allow inbound traffic on port 22, 80 & 8080"
  vpc_id      = aws_default_vpc.default.id

 dynamic "ingress" {
    for_each    = local.security_groups.public.ingress

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
    
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "copy_ssh_key" {
  for_each = aws_instance.my_instances

  connection {
    type        = "ssh"
    host        = each.value.public_ip
    user        = "ubuntu"
    private_key = file("${path.module}/mtc-terransible.pem") # Change to your private key path
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${file("~/.ssh/id_rsa.pub")}' >> ~/.ssh/authorized_keys", # Change to your public key
      "echo 'Copy Completed'"
    ]
  }
}
