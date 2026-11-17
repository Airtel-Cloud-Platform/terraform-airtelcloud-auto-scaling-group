# Airtel Cloud Autoscaling Group Terraform Module

Terraform module for provisioning an Airtel Cloud autoscaling group using `airtelcloud_asg`.

Create, read, import, and delete are supported. Changing configuration forces a new group. The group is placed in the availability zone of the chosen subnet; Terraform rejects the plan when `availability_zone` does not match that subnet.

## Features

- Creates an autoscaling group
- Flavor by ID or name
- Image by ID, name, or snapshot name
- Security group by ID or name
- Optional SSH keypair
- Optional load balancer virtual-server attachment through separate inputs
- Optional labels, boot disk size, and timeouts

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.9 |
| airtelcloud | >= 1.2.6 |

## Usage

### Basic Example

```hcl
module "asg" {
  source = "Airtel-Cloud-Platform/asg/airtelcloud"

  name              = "app-asg"
  vpc_name          = "copper-vpc1"
  subnet            = "subnet1213"
  availability_zone = "S2"

  flavor_name          = "ccd.Large"
  image_name           = "Ubuntu22_04_Sep2026"
  security_group_names = ["networksg-1"]
  keypair_name         = "keypair-1"

  minimum_size  = 1
  maximum_size  = 3
  desired_count = 1

  scale_up_step_size   = 1
  scale_down_step_size = 1
  scaling_interval     = 2
  cooloff_period       = 10
  termination_policy   = "oldest"
  drain_period         = 0

  scaleup_rules = [{
    metric_type      = "cpu"
    aggregation_type = "avg"
    target_value     = 60
  }]

  scaledown_rules = [{
    metric_type      = "cpu"
    aggregation_type = "avg"
    target_value     = 30
  }]
}
```

### With a load balancer

```hcl
module "asg" {
  source = "Airtel-Cloud-Platform/asg/airtelcloud"

  name              = "app-asg-lb"
  vpc_name          = "copper-vpc1"
  subnet            = "subnet1213"
  availability_zone = "S2"

  flavor_name          = "ccd.Large"
  image_name           = "Ubuntu22_04_Sep2026"
  security_group_names = ["networksg-1"]

  minimum_size  = 1
  maximum_size  = 3
  desired_count = 1

  scale_up_step_size   = 1
  scale_down_step_size = 1
  scaling_interval     = 2
  cooloff_period       = 10
  termination_policy   = "oldest"
  drain_period         = 0

  scaleup_rules = [{
    metric_type      = "cpu"
    aggregation_type = "avg"
    target_value     = 60
  }]

  scaledown_rules = [{
    metric_type      = "cpu"
    aggregation_type = "avg"
    target_value     = 30
  }]

  load_balancer_name    = "south-lb"
  host_name             = "app-asg-vs"
  vip                   = "10.29.16.10"
  protocol              = "TCP"
  port                  = 1234
  routing_algorithm     = "ROUND_ROBIN"
  pool_name             = "ash-pool"
  pool_port             = 12
  max_connections       = 100
  health_check_interval = 5
  health_check_timeout  = 16
  pool_monitor_protocol = "TCP"
  enable_persistance    = false
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| name | Group name (min 3 characters) | string | Yes |
| vpc_name | VPC display name | string | Yes |
| subnet | Subnet display name | string | Yes |
| availability_zone | Zone code | string | Yes |
| minimum_size | Minimum group size | number | Yes |
| maximum_size | Maximum group size | number | Yes |
| desired_count | Desired instance count (must equal minimum_size) | number | Yes |
| scale_up_step_size | Instances to add per scale-up (1–3) | number | Yes |
| scale_down_step_size | Instances to remove per scale-down (1–3) | number | Yes |
| scaling_interval | Scaling interval in minutes (2–30) | number | Yes |
| cooloff_period | Cool-off period in seconds (0–300) | number | Yes |
| termination_policy | `oldest`, `newest`, or `random` | string | Yes |
| drain_period | Drain period in seconds (0–300) | number | Yes |
| scaleup_rules | Scale-up metric rules | list(object) | Yes |
| scaledown_rules | Scale-down metric rules | list(object) | Yes |
| flavor_id | Flavor ID (XOR with flavor_name) | number | No |
| flavor_name | Flavor name (XOR with flavor_id) | string | No |
| image_id | Image ID | number | No |
| image_name | Image name | string | No |
| snapshot_name | Compute snapshot name | string | No |
| security_group_ids | One security group ID | list(number) | No |
| security_group_names | One security group name | list(string) | No |
| keypair_id | Keypair UUID | string | No |
| keypair_name | Keypair name | string | No |
| disk_size | Boot volume size in GB. Minimum 20. Defaults to 100, or 200 for Windows images | number | No |
| labels | Labels to assign | list(string) | No |
| load_balancer_name | Existing load balancer service name. Requires every input below except `enable_persistance` | string | No |
| host_name | Virtual server name | string | With load balancer |
| vip | VIP on the load balancer service network | string | With load balancer |
| protocol | Listener protocol, such as `TCP` | string | With load balancer |
| port | Listener port | number | With load balancer |
| routing_algorithm | Pool algorithm, such as `ROUND_ROBIN` | string | With load balancer |
| pool_name | Pool name | string | With load balancer |
| pool_port | Member port | number | With load balancer |
| max_connections | Maximum connections per member | number | With load balancer |
| health_check_interval | Health-check interval in seconds (at least 1) | number | With load balancer |
| health_check_timeout | Health-check timeout in seconds (at least 1) | number | With load balancer |
| pool_monitor_protocol | Health monitor protocol, such as `TCP` | string | With load balancer |
| enable_persistance | Session persistence. Defaults to `false` | bool | No |
| load_balancer | Deprecated. Use the separate inputs above. Cannot be combined with them | object | No |
| timeouts | Create and delete timeouts. The provider default is 15 minutes each | object | No |

Exactly one of `flavor_id` or `flavor_name` is required. Exactly one of `image_id`, `image_name`, or `snapshot_name` is required. Exactly one of `security_group_ids` or `security_group_names` is required.

## Outputs

| Name | Description |
|------|-------------|
| id | Autoscaling group UUID |
| name | Configured group name |
| vpc_id | Resolved VPC ID |
| network_id | Resolved subnet ID |
| availability_zone | Availability zone |
| flavor_id | Resolved flavor ID |
| image_id | Resolved image ID |
| os_type | Image OS family |
| disk_size | Boot volume size in GB |
| security_group_ids | Security group ID attached to the group |
| keypair_id | Keypair UUID, if one is used |
| load_balancer_name | Attached load balancer name, or null |
| asg | Selected attributes for downstream modules |

## Notes

- Configuration changes force a new group. Only `timeouts` can change in place.
- `desired_count` must equal `minimum_size`, and `minimum_size` must be less than `maximum_size`.
- Every `scaleup_rules` metric must appear in `scaledown_rules` with the same `aggregation_type` and a lower `target_value`, and every `scaledown_rules` metric must appear in `scaleup_rules`.
- When `snapshot_name` is set, `keypair_id` or `keypair_name` is required.
- Load balancer attachment uses separate inputs: `load_balancer_name`, `host_name`, `vip`, `protocol`, `port`, `routing_algorithm`, `pool_name`, `pool_port`, `max_connections`, `health_check_interval`, `health_check_timeout`, and `pool_monitor_protocol`. Set all of them or none. `enable_persistance` is optional. The nested `load_balancer` object still works but is deprecated, and it cannot be combined with the separate inputs.
- The VIP comes from the load balancer service network, not the ASG subnet.
- `disk_size` has a minimum of 20 GB. It defaults to 100 GB, or 200 GB for Windows images.
- The default create and delete timeout is 15 minutes. Set `timeouts` to change it, for example `{ create = "20m", delete = "20m" }`.
- Destroying a group that has a load balancer deletes its virtual server first, then the group. Importing an existing group recovers its network, security group, keypair, and load balancer settings. Both need a provider release that includes the fixes from the `fix/asg-import-lb-delete-20261117` branch.
- The `enable_persistance` field name matches the API spelling.
