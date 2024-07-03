output "instance_1_id" {
  description = "ID of the EC2 instance_1"
  value       = aws_instance.instance_1.id
}

output "instance_1_public_ip" {
  description = "Public IP address of the EC2 instance_1"
  value       = aws_instance.instance_1.public_ip
}

output "instance_2_id" {
  description = "ID of the EC2 instance_2"
  value       = aws_instance.instance_2.id
}

output "instance_2_public_ip" {
  description = "Public IP address of the EC2 instance_2"
  value       = aws_instance.instance_2.public_ip
}