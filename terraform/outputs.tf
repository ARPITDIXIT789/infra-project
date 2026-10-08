output "public_ips" {
  description = "Public IPs of web instances (browser mein kholne ke liye)"
  value       = aws_instance.web[*].public_ip
}

output "private_ips" {
  description = "Private IPs of web instances (Ansible SSH ke liye)"
  value       = aws_instance.web[*].private_ip
}
