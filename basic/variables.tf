variable "aws_region" {
  description = "AWS region where Terraform creates the EC2 instance."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "aws_region must not be empty."
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

variable "key_name" {
  description = "Name of an existing EC2 key pair in the selected AWS region."
  type        = string

  validation {
    condition     = length(trimspace(var.key_name)) > 0
    error_message = "key_name must contain an existing EC2 key-pair name."
  }
}

variable "ssh_allowed_cidr" {
  description = "Your public IPv4 address in CIDR notation, normally x.x.x.x/32."
  type        = string

  validation {
    condition = (
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/32$", var.ssh_allowed_cidr)) &&
      can(cidrnetmask(var.ssh_allowed_cidr))
    )
    error_message = "ssh_allowed_cidr must be one valid IPv4 host CIDR ending in /32."
  }
}

variable "project_name" {
  description = "Name used for AWS resource names and tags."
  type        = string
  default     = "terraform-basic-ec2"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{2,31}$", var.project_name))
    error_message = "project_name must be 3-32 characters, start with a letter, and contain only letters, numbers, or hyphens."
  }
}
