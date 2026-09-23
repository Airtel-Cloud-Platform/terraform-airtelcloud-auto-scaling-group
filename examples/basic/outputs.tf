output "asg_id" {
  description = "ID of the autoscaling group."
  value       = module.asg.id
}

output "asg_name" {
  description = "Name of the autoscaling group."
  value       = module.asg.name
}

output "asg_vpc_id" {
  description = "Resolved VPC ID of the autoscaling group."
  value       = module.asg.vpc_id
}

output "asg_network_id" {
  description = "Resolved subnet network ID of the autoscaling group."
  value       = module.asg.network_id
}
