# Airtel Cloud Autoscaling Group Terraform Module

Terraform module for provisioning an Airtel Cloud autoscaling group using `airtelcloud_asg`.

Create, read, import, and delete are supported. Changing configuration forces a new group. The group is placed in the availability zone of the chosen subnet; Terraform rejects the plan when `availability_zone` does not match that subnet.

## Features

- Creates an autoscaling group
- Flavor by ID or name
- Image by ID, name, or snapshot name
- Security group by ID or name
- Optional SSH keypair
- Optional load balancer virtual-server attachment
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

  load_balancer = {
    name                    = "south-lb"
    host_name               = "app-asg-vs"
    vip                     = "10.29.16.10"
    protocol                = "TCP"
    port                    = 1234
    routing_algorithm       = "ROUND_ROBIN"
    pool_name               = "ash-pool"
    pool_port               = 12
    max_connections         = 100
    health_check_interval   = 5
    health_check_timeout    = 16
    pool_monitor_protocol   = "TCP"
    enable_persistance      = false
  }
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
| disk_size | Boot volume size in GB | number | No |
| labels | Labels to assign | list(string) | No |
| load_balancer | Existing LB virtual-server attachment | object | No |
| timeouts | Create and delete timeouts | object | No |

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
| asg | Selected attributes for downstream modules |

## Notes

- Configuration changes force a new group.
- `desired_count` must equal `minimum_size`, and `minimum_size` must be less than `maximum_size`.
- Each `scaleup_rules` metric must appear in `scaledown_rules` with the same `aggregation_type` and a lower `target_value`.
- When `snapshot_name` is set, `keypair_id` or `keypair_name` is required.
- When `load_balancer` is set, the VIP comes from the load balancer service network, not the ASG subnet.
- The `enable_persistance` field name matches the API spelling.
