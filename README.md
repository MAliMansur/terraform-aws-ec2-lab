# Terraform AWS EC2 Lab

A beginner-friendly Infrastructure as Code (IaC) project for launching an
Ubuntu EC2 instance with Terraform.

> **Cost warning:** This project creates real AWS resources. EC2, EBS, public
> IPv4 addresses, and other services can produce charges. Run
> `terraform destroy` when you finish practicing.

## Repository structure

| Folder | Level | What Terraform creates | How you connect |
|---|---|---|---|
| [`basic/`](basic/) | Beginner | One EC2 instance and one security group in the default VPC | SSH with an EC2 key pair |
| [`intermediate/`](intermediate/) | Intermediate | A custom VPC, public subnet, internet gateway, routing, security rules, IAM role, instance profile, and an Nginx EC2 instance | AWS Systems Manager Session Manager by default; optional SSH |

The two folders are independent Terraform root modules. Run Terraform commands
inside **only one folder at a time**. Each folder has its own state.

## Prerequisites

- An AWS account
- Terraform CLI
- AWS CLI v2
- AWS permissions for the resources in the folder you select
- The Session Manager plugin if you use the intermediate lab's SSM terminal

Check the installed commands:

```bash
terraform version
aws --version
```

Official installation pages:

- [Install Terraform](https://developer.hashicorp.com/terraform/install)
- [Install or update AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Install the Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

## Log in to AWS from the Ubuntu terminal

Terraform uses the same AWS credential chain as the AWS CLI. Authenticate the
AWS CLI first, verify the identity, and then run Terraform.

### Option 1: IAM Identity Center (recommended for organizations)

Your company or AWS administrator must first give you an IAM Identity Center
start URL, SSO region, AWS account, and permission set.

Configure a named profile once:

```bash
aws configure sso --profile terraform-lab
```

Log in whenever the SSO session expires:

```bash
aws sso login --profile terraform-lab
export AWS_PROFILE=terraform-lab
```

Your browser will open so you can approve the sign-in. To use a device code
instead, run:

```bash
aws sso login --profile terraform-lab --use-device-code
```

### Option 2: Access keys (simple learning account)

Use this only when your account administrator has given you an access key.
Never use the AWS root user's access keys.

```bash
aws configure --profile terraform-lab
```

Enter the requested values:

```text
AWS Access Key ID: <enter it at the prompt>
AWS Secret Access Key: <enter it at the prompt>
Default region name: us-east-1
Default output format: json
```

Select that profile in the current terminal:

```bash
export AWS_PROFILE=terraform-lab
```

The AWS CLI stores profile configuration under `~/.aws/`. Never type an access
key into a `.tf` file, `terraform.tfvars`, shell script, or GitHub repository.

### Verify the AWS CLI login

```bash
aws sts get-caller-identity
aws configure list
```

`get-caller-identity` should show your AWS account ID and your IAM user or role
ARN. If you see `Unable to locate credentials`, repeat one of the login methods
above and make sure `AWS_PROFILE` is set correctly.

## Which lab should I run first?

Start with the basic lab:

```bash
cd basic
```

Follow [`basic/README.md`](basic/README.md). After you understand providers,
data sources, resources, variables, outputs, state, `plan`, `apply`, and
`destroy`, continue with:

```bash
cd ../intermediate
```

Then follow [`intermediate/README.md`](intermediate/README.md).

## The normal Terraform workflow

Run these commands from either lab folder:

```bash
terraform fmt -check
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

When finished:

```bash
terraform plan -destroy
terraform destroy
```

Type `yes` only after reviewing the destroy plan.

## Important files Terraform creates locally

| File or folder | Purpose | Commit to GitHub? |
|---|---|---|
| `.terraform/` | Downloaded providers and local working data | No |
| `.terraform.lock.hcl` | Exact selected provider versions | Yes |
| `terraform.tfstate` | Mapping between code and real AWS resources; may contain sensitive data | No |
| `terraform.tfvars` | Your local variable values | No |
| `terraform.tfvars.example` | Safe example values | Yes |

This repository's `.gitignore` protects the common local files, state, plans,
and private-key formats, but you should still inspect every commit.

## Useful official documentation

- [Terraform AWS EC2 tutorial](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create)
- [Terraform AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [AWS CLI IAM Identity Center login](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)
- [AWS STS `get-caller-identity`](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html)
- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)

## Publish this project to your GitHub account

The downloaded ZIP intentionally does not contain the hidden `.git/` directory.
After extracting it, you can publish it with GitHub CLI or ordinary Git.

### Method 1: GitHub CLI

Install [GitHub CLI](https://cli.github.com/), open the extracted project
directory, and authenticate:

```bash
cd terraform-aws-ec2-lab
gh auth login
```

Initialize Git and inspect exactly what will be committed:

```bash
git init -b main
git add .
git diff --cached --check
git status --short
```

Confirm that the list contains no `.pem` key, real `terraform.tfvars`,
`.terraform/` directory, plan, or state file. Then create the first commit:

```bash
git commit -m "Add basic and intermediate Terraform EC2 labs"
```

Create a public repository and push the commit:

```bash
gh repo create terraform-aws-ec2-lab \
  --public \
  --source=. \
  --remote=origin \
  --push \
  --description "Beginner and intermediate Terraform labs for launching EC2 on AWS"
```

Use `--private` instead of `--public` if you do not want a portfolio repository.
The command prints the new repository URL when it succeeds.

### Method 2: Git and the GitHub website

1. On GitHub, create an empty repository named `terraform-aws-ec2-lab`.
2. Do not initialize the remote with another README, `.gitignore`, or license;
   this project already contains them.
3. In the extracted local project, run:

```bash
git init -b main
git add .
git diff --cached --check
git status --short
git commit -m "Add basic and intermediate Terraform EC2 labs"
git remote add origin https://github.com/YOUR_USERNAME/terraform-aws-ec2-lab.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username. If Git asks who you
are before the commit, configure the name and verified email associated with
your own GitHub account:

```bash
git config user.name "YOUR NAME"
git config user.email "YOUR VERIFIED GITHUB EMAIL"
```

GitHub account passwords are not accepted for Git operations over HTTPS. Use
GitHub CLI authentication, a supported credential manager, an SSH key, or a
personal access token when prompted.

## Safety checklist

- Restrict SSH to your own public IP with `/32`; never use `0.0.0.0/0` for SSH.
- Do not commit AWS credentials, private keys, state, or real `.tfvars` files.
- Review `terraform plan` before applying it.
- Run `terraform destroy` after the lab and confirm the resources are gone.
- Use short-lived SSO credentials when available.
