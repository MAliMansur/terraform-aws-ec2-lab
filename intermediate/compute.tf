resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm.name
  key_name                    = var.enable_ssh ? var.key_name : null

  user_data                   = file("${path.module}/user-data.sh")
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "${local.name_prefix}-web"
    Role = "web-server"
  }

  lifecycle {
    precondition {
      condition = !var.enable_ssh || (
        var.key_name != null &&
        var.ssh_allowed_cidr != null
      )
      error_message = "When enable_ssh is true, set both key_name and ssh_allowed_cidr."
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core,
    aws_route.internet,
    aws_route_table_association.public
  ]
}
