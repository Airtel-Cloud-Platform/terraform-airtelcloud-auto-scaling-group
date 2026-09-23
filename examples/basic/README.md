# Basic Autoscaling Group Example

This example provisions an autoscaling group using the module from the repository root.

## What This Example Shows

- Single group creation
- Flavor, image, security group, and keypair by name
- CPU scale-up and scale-down rules
- Labels

## Files

- `main.tf`: provider config + module call
- `variables.tf`: input variables used by the provider block
- `outputs.tf`: group ID, name, VPC ID, and network ID

## How To Run

1. Go to this folder:

```bash
cd examples/basic
```

2. Initialize Terraform:

```bash
terraform init
```

3. Provide your own credentials and project details in a tfvars file (do not commit secrets).

4. Plan:

```bash
terraform plan -var-file=terraform.tfvars
```

5. Apply:

```bash
terraform apply -var-file=terraform.tfvars
```

6. Destroy when done:

```bash
terraform destroy -var-file=terraform.tfvars
```

## Notes

- Use your own Airtel Cloud API credentials.
- Update `vpc_name`, `subnet`, flavor, image, security group, and keypair to match your environment.
- Configuration changes force a new group.
