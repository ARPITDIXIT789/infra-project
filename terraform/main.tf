terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region = var.region
}

# ---------- Data Sources ----------

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# ---------- Key Pair ----------

resource "aws_key_pair" "lab" {
  key_name   = "ansible-lab-key"
  public_key = var.ssh_public_key
}

# ---------- Security Group ----------

resource "aws_security_group" "web" {
  name_prefix = "ansible-lab-web-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "SSH from Jenkins"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.jenkins_sg_id]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ansible-lab-web-sg"
  }
}

# ---------- EC2 Instances ----------

resource "aws_instance" "web" {
  count                  = var.node_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.lab.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "web-${count.index + 1}"
    Role = "web"
    Env  = "dev"
  }
}
/*
# ---------- Generate Ansible Inventory ----------

resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventories/dev/hosts.ini"
  content = templatefile("${path.module}/inventory.tftpl", {
    ips = aws_instance.web[*].private_ip
  })
}*/
