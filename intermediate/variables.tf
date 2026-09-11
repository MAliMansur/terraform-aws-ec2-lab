variable "aws_region" {
  description = "AWS region in which to create the lab."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "aws_region must not be empty."
  }
}

variable "project_name" {
  description = "Short project name used in resource names and tags."
  type        = string
  default     = "terraform-ec2"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,23}$", var.project_name))
    error_message = "project_name must be 3-24 lowercase letters, numbers, or hyphens and start with a letter."
  }
}

variable "environment" {
  description = "Environment label used in names and tags."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, stage, prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type. Check current AWS pricing before applying."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = length(trimspace(var.instance_type)) > 0
    error_message = "instance_type must not be empty."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the custom VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidr" {
  description = "IPv4 CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrnetmask(var.public_subnet_cidr))
    error_message = "public_subnet_cidr must be a valid IPv4 CIDR block."
  }
}

variable "http_allowed_cidr" {
  description = "IPv4 CIDR allowed to view the Nginx page. Use 0.0.0.0/0 for a public lab page."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.http_allowed_cidr))
    error_message = "http_allowed_cidr must be a valid IPv4 CIDR block."
  }
}

variable "enable_ssh" {
  description = "Whether to open port 22 and attach an EC2 key pair. SSM access works without SSH."
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Existing EC2 key-pair name. Required only when enable_ssh is true."
  type        = string
  default     = null
  nullable    = true
}

variable "ssh_allowed_cidr" {
  description = "Your public IPv4 host CIDR. Required only when enable_ssh is true; normally x.x.x.x/32."
  type        = string
  default     = null
  nullable    = true
}

variable "root_volume_size" {
  description = "Size of the encrypted root EBS volume in GiB."
  type        = number
  default     = 12

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 100
    error_message = "root_volume_size must be between 8 and 100 GiB for this lab."
  }
}

variable "extra_tags" {
  description = "Optional additional tags applied to all supported AWS resources."
  type        = map(string)
  default     = {}
}
