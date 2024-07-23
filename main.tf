
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

   root_block_device {
    volume_size = var.root_vol_size  # Root volume size in GB
    volume_type = var.root_vol_type
  }

  tags = {
    Name  = "my-instance-${each.key}"
    "Tag" = each.value
  }
}

resource "aws_security_group" "ansible_node_sg" {
  name_prefix = "instance_sg"
  description = "Allow inbound traffic on port 22, 80 & 8080"
  vpc_id      = aws_default_vpc.default.id

 // Add common ingress rules (SSH and HTTP)
  ingress {
    from_port   = local.security_groups.public.ingress.ssh.from_port
    to_port     = local.security_groups.public.ingress.ssh.to_port
    protocol    = local.security_groups.public.ingress.ssh.protocol
    cidr_blocks = local.security_groups.public.ingress.ssh.cidr_blocks
  }

  ingress {
    from_port   = local.security_groups.public.ingress.http.from_port
    to_port     = local.security_groups.public.ingress.http.to_port
    protocol    = local.security_groups.public.ingress.http.protocol
    cidr_blocks = local.security_groups.public.ingress.http.cidr_blocks
  }

// Add specific ingress rules for each instance accordig to the tags
 dynamic "ingress" {
    for_each = {for key, sg in local.security_groups.public.ingress : key => sg if contains(keys(var.instances), key)}
    


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
