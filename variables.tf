variable "instances" {
  default = {
    "jenkins"      = "jenkins"
    "jenkins_node" = "jenkins-node"
    "sonarqube"    = "sonarqube"
    "nexus"        = "nexus"
  }
}

variable "aws_instance_type" {
  default = "t2.micro"
  type    = string
}

variable "ami" {
  default = "ami-0a0e5d9c7acc336f1"
  type    = string

}

variable "instance_count" {
  type = number
}

variable "key_name" {
  default = "mtc-terransible"
}

variable "access_ip" {
 type = string
}

variable "root_vol_type" {
   type   = string
   default = "gp3"
}

variable "root_vol_size" {
   type   = number
   default = 15
}