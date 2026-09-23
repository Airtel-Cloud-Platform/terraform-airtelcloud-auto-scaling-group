# Complete Autoscaling Group Example

This example provisions an autoscaling group attached to an existing load balancer.

## What This Example Shows

- Load balancer virtual-server attachment
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

- `load_balancer.name` must match an existing load balancer service.
- The VIP is taken from the load balancer service network, not the ASG subnet.
- Adjust VPC, subnet, flavor, image, security group, and VIP to match your environment.
- Configuration changes force a new group.
