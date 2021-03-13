
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = "eu-west-1"
    profile = "default"
}

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
    key_name      = var.nombre_clave
    tags = {
        name = var.nombre_maquina
    }
    security_groups = var.security_groups
}

# Crear volúmenes
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume
resource "aws_ebs_volume" "volumen2" {
  availability_zone = aws_instance.mi-maquina-mikel.availability_zone
  size              = 5
  tags = {
    Name = "${aws_instance.mi-maquina-mikel.tags.name}_vol2"
  }
}
resource "aws_volume_attachment" "asignacion_volumen2" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.volumen2.id
  instance_id = aws_instance.mi-maquina-mikel.id
}