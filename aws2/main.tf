
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = var.region_aws
    profile = "default"
}


module "instancias" {
    source         = "./instancias"
    aws_ami_owners = var.aws_ami_owners
    aws_ami_nombre = var.aws_ami_nombre
    volumenes      = var.volumenes
    nombre_clave   = var.id_clave
    nombre_maquina = var.nombre_maquina
    security_groups= module.redes.security_group_id
}

# Creamos el par de claves privada y pública
module "claves" {
    source             = "./claves"
    longitud_clave_rsa = 4096
    id_clave           = var.id_clave
}

module "redes" {
    source      = "./redes"
    nombre_vpc  = var.nombre_vpc
    cidr_vpc    = var.cidr_vpc
    subnets     = var.subnets
}

