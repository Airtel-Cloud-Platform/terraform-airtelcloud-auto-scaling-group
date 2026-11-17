output "id" {
  description = "UUID of the autoscaling group."
  value       = airtelcloud_asg.this.id
}

output "name" {
  description = "Configured autoscaling group name."
  value       = airtelcloud_asg.this.name
}

output "vpc_id" {
  description = "Resolved VPC ID."
  value       = airtelcloud_asg.this.vpc_id
}

output "network_id" {
  description = "Resolved subnet network ID."
  value       = airtelcloud_asg.this.network_id
}

output "availability_zone" {
  description = "Availability zone of the group."
  value       = airtelcloud_asg.this.availability_zone
}

output "flavor_id" {
  description = "Resolved flavor ID."
  value       = airtelcloud_asg.this.flavor_id
}

output "image_id" {
  description = "Resolved image ID. Empty for snapshot-based groups."
  value       = airtelcloud_asg.this.image_id
}

output "os_type" {
  description = "Image OS family. Empty for snapshot-based groups."
  value       = airtelcloud_asg.this.os_type
}

output "disk_size" {
  description = "Boot volume size in GB."
  value       = airtelcloud_asg.this.disk_size
}

output "security_group_ids" {
  description = "Security group ID attached to the group."
  value       = airtelcloud_asg.this.security_group_ids
}

output "keypair_id" {
  description = "Keypair UUID, if one is used."
  value       = airtelcloud_asg.this.keypair_id
}

output "load_balancer_name" {
  description = "Name of the attached load balancer. Null when the group has none."
  value       = airtelcloud_asg.this.load_balancer_name
}

output "asg" {
  description = "Selected autoscaling group attributes for downstream modules."

  value = {
    id                 = airtelcloud_asg.this.id
    name               = airtelcloud_asg.this.name
    vpc_id             = airtelcloud_asg.this.vpc_id
    network_id         = airtelcloud_asg.this.network_id
    availability_zone  = airtelcloud_asg.this.availability_zone
    flavor_id          = airtelcloud_asg.this.flavor_id
    image_id           = airtelcloud_asg.this.image_id
    os_type            = airtelcloud_asg.this.os_type
    disk_size          = airtelcloud_asg.this.disk_size
    security_group_ids = airtelcloud_asg.this.security_group_ids
    keypair_id         = airtelcloud_asg.this.keypair_id
    load_balancer_name = airtelcloud_asg.this.load_balancer_name
  }
}
