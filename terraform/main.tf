provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "jenkins-terraform-state-theo-mrn"
    key    = "jenkins-training/terraform.tfstate"
    region = "eu-west-3"
  }
}

# Récupération dynamique de la dernière AMI Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 1. Groupe de sécurité (Pare-feu)
resource "aws_security_group" "flask_app_sg" {
  name        = "flask-app-sg"
  description = "Allow HTTP on 5000 and SSH"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Attention: ouvert à tout internet
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. L'instance EC2
resource "aws_instance" "app_server" {

  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.flask_app_sg.id]

  tags = {
    Name = "Jenkins-Flask-App"
  }
}
