# Basic EC2 lab

This folder teaches the smallest useful Terraform EC2 workflow. It uses your
AWS account's **default VPC** and creates:

- one security group that permits SSH only from your public IP;
- one Ubuntu 24.04 LTS EC2 instance;
- one encrypted `gp3` root volume.

## Concepts in this folder

| Terraform item | Simple meaning | Example here |
|---|---|---|
| Provider | The plugin Terraform uses to talk to a platform | `hashicorp/aws` |
| Data source | Reads something that already exists | Latest Ubuntu AMI and default VPC |
| Resource | Creates or manages something | Security group and EC2 instance |
| Variable | Input you can change | Region, instance type, key name, your IP |
| Output | Useful value Terraform prints | Instance ID, public IP, SSH command |
| State | Terraform's record of managed infrastructure | Local `terraform.tfstate` |

## Step 1: Authenticate the AWS CLI

Follow the [AWS CLI login instructions in the main README](../README.md#log-in-to-aws-from-the-ubuntu-terminal), then verify:

```bash
aws sts get-caller-identity
```

## Step 2: Create or select an EC2 key pair

List the key pairs in your selected region:

```bash
aws ec2 describe-key-pairs \
  --region us-east-1 \
  --query 'KeyPairs[].KeyName' \
  --output table
```

If you already have a key and its private `.pem` file, use that key's name in
`terraform.tfvars` and skip creation.

To create a new key from the CLI, run this from your home or SSH directory,
**not from this Git repository**:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
umask 077
aws ec2 create-key-pair \
  --region us-east-1 \
  --key-name terraform-ec2-key \
  --key-type rsa \
  --key-format pem \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/terraform-ec2-key.pem
chmod 400 ~/.ssh/terraform-ec2-key.pem
```

AWS returns the private key only when the key pair is created. Back it up
safely and never commit it to Git.

## Step 3: Find your public IPv4 address

```bash
curl --fail --silent https://checkip.amazonaws.com
```

If the result is `198.51.100.25`, your host-only CIDR is
`198.51.100.25/32`. Do not use `0.0.0.0/0` for SSH.

## Step 4: Set your variables

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Change at least:

```hcl
key_name         = "terraform-ec2-key"
ssh_allowed_cidr = "YOUR.PUBLIC.IP/32"
```

The key pair and EC2 instance must be in the same AWS region.

## Step 5: Initialize and check the code

```bash
terraform fmt -check
terraform init
terraform validate
```

`terraform init` downloads the AWS provider and creates
`.terraform.lock.hcl`. Commit the lock file to Git; do not commit `.terraform/`.

## Step 6: Preview and create the EC2 instance

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

Terraform prints the instance ID, public IP, and an SSH command.

## Step 7: Log in to the EC2 terminal with SSH

```bash
terraform output -raw ssh_command
```

Run the printed command, or run:

```bash
ssh -i ~/.ssh/terraform-ec2-key.pem \
  ubuntu@"$(terraform output -raw public_ip)"
```

Type `yes` the first time SSH asks whether you trust the host fingerprint.
Inside the EC2 instance, try:

```bash
hostname
cat /etc/os-release
free -h
df -h
exit
```

## Step 8: Destroy the lab

Back in the `basic/` directory:

```bash
terraform plan -destroy
terraform destroy
```

Review the plan, type `yes`, and then confirm that Terraform reports the
resources were destroyed.

## Common errors

| Error | Likely reason | Fix |
|---|---|---|
| `Unable to locate credentials` | AWS CLI is not authenticated | Configure/login to the profile and export `AWS_PROFILE` |
| `InvalidKeyPair.NotFound` | Key pair is absent from the selected region | Create/select a key pair in the same region |
| SSH timeout | Wrong IP CIDR, changed internet IP, or blocked port 22 | Update `ssh_allowed_cidr`, apply again, and check local/network firewall rules |
| `Permission denied (publickey)` | Wrong private key or login user | Use the matching `.pem` file and Ubuntu user `ubuntu` |
| No default VPC found | The account's default VPC was deleted | Recreate a default VPC or use the intermediate folder's custom VPC |
