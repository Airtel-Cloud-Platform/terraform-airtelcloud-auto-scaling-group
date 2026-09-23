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

  load_balancer_name    = try(var.load_balancer.name, null)
  host_name             = try(var.load_balancer.host_name, null)
  vip                   = try(var.load_balancer.vip, null)
  protocol              = try(var.load_balancer.protocol, null)
  port                  = try(var.load_balancer.port, null)
  routing_algorithm     = try(var.load_balancer.routing_algorithm, null)
  pool_name             = try(var.load_balancer.pool_name, null)
  pool_port             = try(var.load_balancer.pool_port, null)
  max_connections       = try(var.load_balancer.max_connections, null)
  health_check_interval = try(var.load_balancer.health_check_interval, null)
  health_check_timeout  = try(var.load_balancer.health_check_timeout, null)
  pool_monitor_protocol = try(var.load_balancer.pool_monitor_protocol, null)
  enable_persistance    = try(var.load_balancer.enable_persistance, null)

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
