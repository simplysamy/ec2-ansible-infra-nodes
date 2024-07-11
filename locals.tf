# ----root/locals.tf----


locals {
  security_groups = {
    public = {
      name        = "public_sg"
      description = "Security Group for Public Subnet"

      ingress = {
        ssh = {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }

        http = {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }

        jenkins = {
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
  }
      }
    }

  }
}
