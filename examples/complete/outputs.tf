output "asg_id" {
  description = "ID of the autoscaling group."
  value       = module.asg.id
}

output "asg_name" {
  description = "Name of the autoscaling group."
  value       = module.asg.name
}

output "asg" {
  description = "Selected autoscaling group attributes."
  value       = module.asg.asg
}
