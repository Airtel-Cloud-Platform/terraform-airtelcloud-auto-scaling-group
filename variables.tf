#########################################
# Identity and placement
#########################################

variable "name" {
  description = "Autoscaling group name. Minimum length 3. Forces a new resource."
  type        = string

  validation {
    condition     = length(var.name) >= 3
    error_message = "name must be at least 3 characters."
  }
}

variable "vpc_name" {
  description = "VPC display name. Lowercase letters, digits, and hyphens only. Forces a new resource."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.vpc_name))
    error_message = "vpc_name must contain only lowercase letters, digits, and hyphens."
  }
}

variable "subnet" {
  description = "Subnet display name in the VPC. Must be in the same zone as availability_zone. Forces a new resource."
  type        = string

  validation {
    condition     = length(trim(var.subnet, " ")) > 0
    error_message = "subnet cannot be empty."
  }
}

variable "availability_zone" {
  description = "Zone code (for example S1). Forces a new resource."
  type        = string

  validation {
    condition     = length(trim(var.availability_zone, " ")) > 0
    error_message = "availability_zone cannot be empty."
  }
}

#########################################
# Capacity
#########################################

variable "minimum_size" {
  description = "Minimum group size. Must be at least 1 and less than maximum_size. Forces a new resource."
  type        = number

  validation {
    condition     = var.minimum_size >= 1
    error_message = "minimum_size must be at least 1."
  }
}

variable "maximum_size" {
  description = "Maximum group size. Must be at least 1. Forces a new resource."
  type        = number

  validation {
    condition     = var.maximum_size >= 1
    error_message = "maximum_size must be at least 1."
  }

  validation {
    condition     = var.minimum_size < var.maximum_size
    error_message = "minimum_size must be less than maximum_size."
  }
}

variable "desired_count" {
  description = "Desired instance count. Must equal minimum_size. Forces a new resource."
  type        = number

  validation {
    condition     = var.desired_count >= 1
    error_message = "desired_count must be at least 1."
  }

  validation {
    condition     = var.desired_count == var.minimum_size
    error_message = "desired_count must equal minimum_size."
  }
}

#########################################
# Scaling policy
#########################################

variable "scale_up_step_size" {
  description = "Instances to add per scale-up. Between 1 and 3. Forces a new resource."
  type        = number

  validation {
    condition     = var.scale_up_step_size >= 1 && var.scale_up_step_size <= 3
    error_message = "scale_up_step_size must be between 1 and 3."
  }
}

variable "scale_down_step_size" {
  description = "Instances to remove per scale-down. Between 1 and 3. Forces a new resource."
  type        = number

  validation {
    condition     = var.scale_down_step_size >= 1 && var.scale_down_step_size <= 3
    error_message = "scale_down_step_size must be between 1 and 3."
  }
}

variable "scaling_interval" {
  description = "Scaling interval in minutes. Between 2 and 30. Forces a new resource."
  type        = number

  validation {
    condition     = var.scaling_interval >= 2 && var.scaling_interval <= 30
    error_message = "scaling_interval must be between 2 and 30."
  }
}

variable "cooloff_period" {
  description = "Cool-off period in seconds. Between 0 and 300. Forces a new resource."
  type        = number

  validation {
    condition     = var.cooloff_period >= 0 && var.cooloff_period <= 300
    error_message = "cooloff_period must be between 0 and 300."
  }
}

variable "termination_policy" {
  description = "Instance termination policy. One of oldest, newest, random. Forces a new resource."
  type        = string

  validation {
    condition     = contains(["oldest", "newest", "random"], var.termination_policy)
    error_message = "termination_policy must be one of oldest, newest, random."
  }
}

variable "drain_period" {
  description = "Drain period in seconds. Between 0 and 300. Forces a new resource."
  type        = number

  validation {
    condition     = var.drain_period >= 0 && var.drain_period <= 300
    error_message = "drain_period must be between 0 and 300."
  }
}

variable "scaleup_rules" {
  description = "Scale-up metric rules. At least one rule. Each metric_type must also appear in scaledown_rules with the same aggregation_type and a lower target_value. Forces a new resource."

  type = list(object({
    metric_type      = string
    aggregation_type = string
    target_value     = number
  }))

  validation {
    condition     = length(var.scaleup_rules) >= 1
    error_message = "scaleup_rules must contain at least one rule."
  }
}

variable "scaledown_rules" {
  description = "Scale-down metric rules. Same nested fields as scaleup_rules. Forces a new resource."

  type = list(object({
    metric_type      = string
    aggregation_type = string
    target_value     = number
  }))

  validation {
    condition     = length(var.scaledown_rules) >= 1
    error_message = "scaledown_rules must contain at least one rule."
  }

  validation {
    condition = alltrue([
      for up in var.scaleup_rules : anytrue([
        for down in var.scaledown_rules :
        down.metric_type == up.metric_type &&
        down.aggregation_type == up.aggregation_type &&
        down.target_value < up.target_value
      ])
    ])
    error_message = "Each scaleup_rules metric_type must appear in scaledown_rules with the same aggregation_type and a lower target_value."
  }
}

#########################################
# Compute image and flavor
#########################################

variable "flavor_id" {
  description = "Flavor ID. Mutually exclusive with flavor_name. Forces a new resource."
  type        = number
  default     = null
}

variable "flavor_name" {
  description = "Flavor name. Mutually exclusive with flavor_id. Forces a new resource."
  type        = string
  default     = null

  validation {
    condition     = (var.flavor_id != null) != (var.flavor_name != null)
    error_message = "Specify exactly one of flavor_id or flavor_name."
  }
}

variable "image_id" {
  description = "Image ID. Mutually exclusive with image_name and snapshot_name. Forces a new resource."
  type        = number
  default     = null
}

variable "image_name" {
  description = "Image name. Mutually exclusive with image_id and snapshot_name. Forces a new resource."
  type        = string
  default     = null
}

variable "snapshot_name" {
  description = "Compute snapshot name. Mutually exclusive with image_id and image_name. Requires keypair_id or keypair_name. Forces a new resource."
  type        = string
  default     = null

  validation {
    condition = length(compact([
      var.image_id != null ? tostring(var.image_id) : null,
      var.image_name,
      var.snapshot_name,
    ])) == 1
    error_message = "Specify exactly one of image_id, image_name, or snapshot_name."
  }

  validation {
    condition     = var.snapshot_name == null || var.keypair_id != null || var.keypair_name != null
    error_message = "keypair_id or keypair_name is required with snapshot_name."
  }
}

#########################################
# Security and auth
#########################################

variable "security_group_ids" {
  description = "One security group ID. Mutually exclusive with security_group_names. Forces a new resource."
  type        = list(number)
  default     = null

  validation {
    condition     = var.security_group_ids == null || length(var.security_group_ids) == 1
    error_message = "security_group_ids must contain exactly one ID when set."
  }
}

variable "security_group_names" {
  description = "One security group name. Mutually exclusive with security_group_ids. Forces a new resource."
  type        = list(string)
  default     = null

  validation {
    condition     = var.security_group_names == null || length(var.security_group_names) == 1
    error_message = "security_group_names must contain exactly one name when set."
  }

  validation {
    condition     = (var.security_group_ids != null) != (var.security_group_names != null)
    error_message = "Specify exactly one of security_group_ids or security_group_names."
  }
}

variable "keypair_id" {
  description = "Keypair UUID. Mutually exclusive with keypair_name. Forces a new resource."
  type        = string
  default     = null
}

variable "keypair_name" {
  description = "Keypair name. Mutually exclusive with keypair_id. Forces a new resource."
  type        = string
  default     = null

  validation {
    condition     = !(var.keypair_id != null && var.keypair_name != null)
    error_message = "keypair_id and keypair_name are mutually exclusive."
  }
}

#########################################
# Optional extras
#########################################

variable "disk_size" {
  description = "Boot volume size in GB. Minimum 20. Defaults to 100, or 200 for Windows images. Forces a new resource."
  type        = number
  default     = null

  validation {
    condition     = var.disk_size == null || var.disk_size >= 20
    error_message = "disk_size must be at least 20 GB."
  }
}

variable "labels" {
  description = "Labels to assign. Forces a new resource."
  type        = list(string)
  default     = null
}

variable "load_balancer" {
  description = "Optional attachment to an existing load balancer service. The VIP is resolved from the load balancer service network, not the autoscaling-group subnet. Forces a new resource."

  type = object({
    name                  = string
    host_name             = string
    vip                   = string
    protocol              = string
    port                  = number
    routing_algorithm     = string
    pool_name             = string
    pool_port             = number
    max_connections       = number
    health_check_interval = number
    health_check_timeout  = number
    pool_monitor_protocol = string
    enable_persistance    = optional(bool, false)
  })

  default = null

  validation {
    condition = (
      var.load_balancer == null ||
      (
        var.load_balancer.health_check_interval >= 1 &&
        var.load_balancer.health_check_timeout >= 1
      )
    )
    error_message = "load_balancer health_check_interval and health_check_timeout must be at least 1."
  }
}

variable "timeouts" {
  description = "Create and delete timeouts for the autoscaling group. Defaults to 15 minutes in the provider."

  type = object({
    create = optional(string)
    delete = optional(string)
  })

  default = null
}
