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

output "asg" {
  description = "Selected autoscaling group attributes for downstream modules."

  value = {
    id                = airtelcloud_asg.this.id
    name              = airtelcloud_asg.this.name
    vpc_id            = airtelcloud_asg.this.vpc_id
    network_id        = airtelcloud_asg.this.network_id
    availability_zone = airtelcloud_asg.this.availability_zone
    flavor_id         = airtelcloud_asg.this.flavor_id
    image_id          = airtelcloud_asg.this.image_id
    os_type           = airtelcloud_asg.this.os_type
  }
}
