output "aws_region" {
  description = "AWS region containing the lab."
  value       = var.aws_region
}

output "instance_id" {
  description = "ID of the Nginx EC2 instance."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IPv4 address of the Nginx EC2 instance."
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "URL of the sample Nginx page. It may take a few minutes after apply to become ready."
  value       = "http://${aws_instance.web.public_ip}"
}

output "ssm_start_session_command" {
  description = "Command to open a terminal without exposing SSH."
  value       = "aws ssm start-session --target ${aws_instance.web.id} --region ${var.aws_region}"
}

output "ssh_command" {
  description = "SSH command when enable_ssh is true."
  value = var.enable_ssh ? (
    "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.web.public_ip}"
  ) : "SSH is disabled. Use the ssm_start_session_command output."
}

output "vpc_id" {
  description = "ID of the custom VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}

output "availability_zone" {
  description = "Availability Zone selected for the public subnet."
  value       = aws_subnet.public.availability_zone
}

output "selected_ami_id" {
  description = "Ubuntu AMI selected dynamically for this AWS region."
  value       = data.aws_ami.ubuntu.id
}
