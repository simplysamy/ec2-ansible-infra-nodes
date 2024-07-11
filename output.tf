output "instance_public_ips" {
  description = "The public IPs of the instances"
  value = {
    for key, instance in aws_instance.my_instances :
    key => instance.public_ip
  }
}

output "instance_private_ips" {
  description = "The private IPs of the instances"
  value = {
    for key, instance in aws_instance.my_instances :
    key => instance.private_ip
  }
}
