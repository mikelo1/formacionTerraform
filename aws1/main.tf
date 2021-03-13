terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
        tls = {
            source = "hashicorp/tls"
        }
    }
}

provider "aws" {
    region = "eu-west-1"
    profile = "default"
}

provider "tls" {}

# La marca data obtiene información del proveedor
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "ami_ubuntu" {
    most_recent = true
    owners = [ "099720109477" ]
    
    filter {
        name   ="name"
        values = [ "*ubuntu-xenial-16.04-amd64-server-*" ]
    }
    
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "mi-maquina-mikel"{
    ami           = data.aws_ami.ami_ubuntu.id
    instance_type = "t2.micro"
    key_name      = aws_key_pair.claves_aws.key_name
    tags = {
        name = "MaqMikel"
    }
    security_groups = [ aws_security_group.reglas_red_mikel.name ]
    provisioner "local-exec" {
        command = "echo \"${self.public_ip} ansible_connection=ssh ansible_port=22 ansible_user=ubuntu ansible_ssh_private_key_file=./clave_privada.pem\" > inventario.ini"
    }
    provisioner "local-exec" {
        command = "ansible-playbook -i inventario.ini mi-playbook.yaml"
    }
    connection {
        type        = "ssh"
        host        = self.public_ip
        user        = "ubuntu"
        private_key = tls_private_key.claves.private_key_pem
        port        = 22
    }
    provisioner "remote-exec" {
        inline = [ "sudo apt-get update && sudo apt-get install python -y" ]
    }
}

#
# Creamos el par de claves privada y pública
#
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "claves" {
    algorithm= "RSA"
    rsa_bits = "4096"
    provisioner "local-exec" {
        command = "echo \"${self.private_key_pem}\" > clave_privada.pem"
    }
    provisioner "local-exec" {
        command = "echo \"${self.public_key_pem}\" > clave_publica.pem"
    }
    provisioner "local-exec" {
        command = "chmod 700 clave_privada.pem"
    }
    provisioner "local-exec" {
        command = "chmod 700 clave_publica.pem"
    }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "claves_aws" {
    key_name   = "mi-clave-mikel"
    public_key = tls_private_key.claves.public_key_openssh
}

output "mi_clave_privada" {
    value = tls_private_key.claves.private_key_pem
}

output "mi_clave_publica" {
    value = tls_private_key.claves.public_key_pem
}


# Crear security group para conectarnos a la máquina
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "reglas_red_mikel" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
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