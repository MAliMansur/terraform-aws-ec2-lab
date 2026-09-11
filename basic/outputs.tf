output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IPv4 address of the EC2 instance."
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_instance.this.public_dns
}

output "selected_ami_id" {
  description = "Ubuntu AMI selected dynamically for this AWS region."
  value       = data.aws_ami.ubuntu.id
}

output "ssh_command" {
  description = "Example SSH command. Replace the key path if yours is different."
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.this.public_ip}"
}
