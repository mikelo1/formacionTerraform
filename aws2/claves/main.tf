terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
        tls = {
            source ="hashicorp/tls"
        }
    }
}

provider "tls" {}

# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
resource "tls_private_key" "clave_privada" {
    algorithm   = "RSA"
    rsa_bits    = var.longitud_clave_rsa
    
    provisioner "local-exec" {
        command = "echo \"${self.private_key_pem}\" > ${var.id_clave}_pri.pem"
    }

    provisioner "local-exec" {
        command = "echo \"${self.public_key_pem}\" > ${var.id_clave}_pub.pem"
    }

    provisioner "local-exec" {
        command = "chmod 700 ${var.id_clave}_pri.pem"
    }

    provisioner "local-exec" {
        command = "chmod 700 ${var.id_clave}_pub.pem"
    }

}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "claves_aws" {
  key_name   = var.id_clave
  public_key = tls_private_key.clave_privada.public_key_openssh
}