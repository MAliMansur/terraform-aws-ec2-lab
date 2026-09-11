# Intermediate EC2 lab

This folder builds a small but more realistic AWS environment around one EC2
instance. It creates:

- a custom VPC;
- one public subnet in the first available Availability Zone;
- an internet gateway, route table, default internet route, and association;
- a security group with public HTTP and optional restricted SSH;
- an IAM role and instance profile for Systems Manager;
- an Ubuntu 24.04 EC2 instance with IMDSv2 and encrypted `gp3` storage;
- Nginx installed through an EC2 user-data script.

This is a learning architecture, not a complete production design. The server
has a public IP and the example exposes HTTP to the configured CIDR.

## How the traffic flows

- Web requests enter through the internet gateway, reach the public subnet,
  pass the HTTP security-group rule, and arrive at Nginx on the EC2 instance.
- Terminal sessions start in your AWS CLI, pass through Systems Manager, and
  reach the SSM Agent running on the EC2 instance.

SSM is the default terminal method, so inbound port 22 stays closed and an SSH
key is not required.

## Step 1: Authenticate the AWS CLI

Follow the [AWS CLI login instructions in the main README](../README.md#log-in-to-aws-from-the-ubuntu-terminal), then verify:

```bash
aws sts get-caller-identity
```

The authenticated identity needs permissions for EC2/VPC resources, IAM roles
and instance profiles, managed-policy attachment, and Systems Manager actions.

## Step 2: Set your values

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

For the first run, you can keep SSH disabled:

```hcl
enable_ssh       = false
key_name         = null
ssh_allowed_cidr = null
```

Check that the selected region and instance type are suitable for your account
and current AWS pricing.

## Step 3: Initialize, validate, and plan

```bash
terraform fmt -check
terraform init
terraform validate
terraform plan -out=tfplan
```

Read the plan. You should see the VPC/network, security, IAM, and EC2 resources
being added.

## Step 4: Create the infrastructure

```bash
terraform apply tfplan
terraform output
```

Provisioning Nginx and registering the SSM Agent can continue for a few minutes
after Terraform reports that the EC2 instance exists.

Check the website URL:

```bash
terraform output -raw website_url
curl "$(terraform output -raw website_url)"
```

Open the printed URL in a browser. If it is not ready yet, wait a minute and
retry. You can inspect cloud-init after connecting to the terminal.

## Step 5: Log in to the EC2 terminal through AWS CLI and SSM

Install the Session Manager plugin on your Ubuntu computer by following the
[official AWS instructions](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html), then verify it:

```bash
session-manager-plugin
```

Print the prepared command:

```bash
terraform output -raw ssm_start_session_command
```

Run it directly with Terraform's output values:

```bash
aws ssm start-session \
  --target "$(terraform output -raw instance_id)" \
  --region "$(terraform output -raw aws_region)"
```

You are now in the EC2 terminal without opening port 22. Try:

```bash
whoami
hostname
systemctl status nginx --no-pager
cloud-init status --long
exit
```

If AWS says `TargetNotConnected`, wait two or three minutes. Then check whether
the instance is registered:

```bash
aws ssm describe-instance-information \
  --filters "Key=InstanceIds,Values=$(terraform output -raw instance_id)" \
  --region "$(terraform output -raw aws_region)"
```

Also confirm that your local CLI is using the intended profile:

```bash
aws sts get-caller-identity
aws configure list
```

## Optional: enable SSH

SSM is preferred for this lab. If you also want to practice SSH, first create
or select an EC2 key pair as described in the [basic lab](../basic/README.md#step-2-create-or-select-an-ec2-key-pair). Then change:

```hcl
enable_ssh       = true
key_name         = "terraform-ec2-key"
ssh_allowed_cidr = "YOUR.PUBLIC.IP/32"
```

Apply the change:

```bash
terraform plan -out=tfplan
terraform apply tfplan
terraform output -raw ssh_command
```

Never set the SSH CIDR to `0.0.0.0/0`.

## Inspect what Terraform manages

```bash
terraform state list
terraform show
terraform output
```

Notice how references such as `aws_vpc.this.id` create dependency relationships
without manually writing resource IDs.

## Destroy everything after practice

```bash
terraform plan -destroy
terraform destroy
```

Review the destroy plan and type `yes`. Confirm there are no remaining lab EC2,
EBS, VPC, public IPv4, or IAM resources in your AWS account.

## Common errors

| Error | Likely reason | Fix |
|---|---|---|
| `AccessDenied` while creating IAM resources | Your identity cannot create/attach the SSM role | Ask the account administrator for the required lab permissions |
| `TargetNotConnected` | SSM Agent is still starting or cannot reach AWS | Wait, check the public route/egress, IAM profile, and EC2 system log |
| Website times out | Nginx is still installing, HTTP CIDR blocks you, or cloud-init failed | Retry, check `cloud-init status --long`, `/var/log/cloud-init-output.log`, and the HTTP rule |
| `InvalidKeyPair.NotFound` after enabling SSH | Key pair is not in this region | Create/select the key in the same region as the instance |
| CIDR overlap or invalid CIDR | Subnet CIDR is outside/invalid for the VPC | Keep the example `10.0.0.0/16` VPC and `10.0.1.0/24` subnet or select a valid contained range |
