locals {
  # Load balancer attachment uses separate inputs. The deprecated load_balancer
  # object is still accepted and supplies the same values; a precondition rejects
  # using both at once.
  load_balancer_name    = try(var.load_balancer.name, var.load_balancer_name)
  host_name             = try(var.load_balancer.host_name, var.host_name)
  vip                   = try(var.load_balancer.vip, var.vip)
  protocol              = try(var.load_balancer.protocol, var.protocol)
  port                  = try(var.load_balancer.port, var.port)
  routing_algorithm     = try(var.load_balancer.routing_algorithm, var.routing_algorithm)
  pool_name             = try(var.load_balancer.pool_name, var.pool_name)
  pool_port             = try(var.load_balancer.pool_port, var.pool_port)
  max_connections       = try(var.load_balancer.max_connections, var.max_connections)
  health_check_interval = try(var.load_balancer.health_check_interval, var.health_check_interval)
  health_check_timeout  = try(var.load_balancer.health_check_timeout, var.health_check_timeout)
  pool_monitor_protocol = try(var.load_balancer.pool_monitor_protocol, var.pool_monitor_protocol)
  enable_persistance    = try(var.load_balancer.enable_persistance, var.enable_persistance)

  # Inputs that are only meaningful together with load_balancer_name.
  load_balancer_dependent_inputs = {
    host_name             = local.host_name
    vip                   = local.vip
    protocol              = local.protocol
    port                  = local.port
    routing_algorithm     = local.routing_algorithm
    pool_name             = local.pool_name
    pool_port             = local.pool_port
    max_connections       = local.max_connections
    health_check_interval = local.health_check_interval
    health_check_timeout  = local.health_check_timeout
    pool_monitor_protocol = local.pool_monitor_protocol
  }
  load_balancer_missing = sort([for k, v in local.load_balancer_dependent_inputs : k if v == null])
  load_balancer_extra   = sort([for k, v in local.load_balancer_dependent_inputs : k if v != null])

  separate_load_balancer_inputs_set = anytrue([
    var.load_balancer_name != null,
    var.host_name != null,
    var.vip != null,
    var.protocol != null,
    var.port != null,
    var.routing_algorithm != null,
    var.pool_name != null,
    var.pool_port != null,
    var.max_connections != null,
    var.health_check_interval != null,
    var.health_check_timeout != null,
    var.pool_monitor_protocol != null,
    var.enable_persistance,
  ])
}

resource "airtelcloud_asg" "this" {
  name              = var.name
  vpc_name          = var.vpc_name
  subnet            = var.subnet
  availability_zone = var.availability_zone

  minimum_size  = var.minimum_size
  maximum_size  = var.maximum_size
  desired_count = var.desired_count

  scale_up_step_size   = var.scale_up_step_size
  scale_down_step_size = var.scale_down_step_size
  scaling_interval     = var.scaling_interval
  cooloff_period       = var.cooloff_period
  termination_policy   = var.termination_policy
  drain_period         = var.drain_period

  scaleup_rules   = var.scaleup_rules
  scaledown_rules = var.scaledown_rules

  flavor_id   = var.flavor_id
  flavor_name = var.flavor_name

  image_id      = var.image_id
  image_name    = var.image_name
  snapshot_name = var.snapshot_name

  security_group_ids   = var.security_group_ids
  security_group_names = var.security_group_names

  keypair_id   = var.keypair_id
  keypair_name = var.keypair_name

  disk_size = var.disk_size
  labels    = var.labels

  load_balancer_name    = local.load_balancer_name
  host_name             = local.host_name
  vip                   = local.vip
  protocol              = local.protocol
  port                  = local.port
  routing_algorithm     = local.routing_algorithm
  pool_name             = local.pool_name
  pool_port             = local.pool_port
  max_connections       = local.max_connections
  health_check_interval = local.health_check_interval
  health_check_timeout  = local.health_check_timeout
  pool_monitor_protocol = local.pool_monitor_protocol
  enable_persistance    = local.enable_persistance

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  lifecycle {
    precondition {
      condition     = var.load_balancer == null || !local.separate_load_balancer_inputs_set
      error_message = "Use either the deprecated load_balancer object or the separate load balancer inputs (load_balancer_name, host_name, vip, and so on), not both."
    }

    precondition {
      condition     = local.load_balancer_name != null || length(local.load_balancer_extra) == 0
      error_message = "These load balancer inputs require load_balancer_name: ${join(", ", local.load_balancer_extra)}."
    }

    precondition {
      condition     = local.load_balancer_name == null || length(local.load_balancer_missing) == 0
      error_message = "load_balancer_name also requires: ${join(", ", local.load_balancer_missing)}."
    }
  }
}
