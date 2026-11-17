# Complete Autoscaling Group Example

This example provisions an autoscaling group attached to an existing load balancer.

## What This Example Shows

- Load balancer virtual-server attachment through separate inputs (`load_balancer_name`, `host_name`, `vip`, `protocol`, `port`, and the rest)
- Boot disk size
- Labels
- Resource timeouts

## Files

- `main.tf`: complete provider and module configuration
- `variables.tf`: provider credentials and name prefix
- `outputs.tf`: group ID, name, and selected attributes

## How To Run

1. Go to this folder:

```bash
cd examples/complete
```

2. Initialize Terraform:

```bash
terraform init
```

3. Set required provider variables (API key/secret, organization, project).

4. Plan:

```bash
terraform plan
```

5. Apply:

```bash
terraform apply
```

6. Destroy when done:

```bash
terraform destroy
```

## Notes

- `load_balancer_name` must match an existing load balancer service. Every other load balancer input is required with it.
- The VIP is taken from the load balancer service network, not the ASG subnet.
- Adjust VPC, subnet, flavor, image, security group, and VIP to match your environment.
- Destroying the group deletes its virtual server first, then the group. This needs a provider release that includes that fix.
- Configuration changes force a new group.
