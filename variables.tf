variable "instances" {
  default = {
    "jenkins"      = "Jenkins"
    "jenkins_node" = "Jenkins-Node"
    "sonarqube"    = "SonarQube"
    "nexus"        = "Nexus"
  }
}

variable "aws_instance_type" {
  default = "t2.micro"
  type    = string
}

variable "ami" {
  default = "ami-080e1f13689e07408"
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
