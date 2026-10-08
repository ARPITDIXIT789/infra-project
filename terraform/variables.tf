variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "node_count" {
  description = "Number of web EC2 instances"
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type for web nodes"
  default     = "t3.micro"
}

variable "ssh_public_key" {
  description = "SSH public key content for ansible-master-key"
  type        = string
}

variable "jenkins_sg_id" {
  description = "Security group ID of the Jenkins server (for SSH access)"
  type        = string
}
