
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "vpc" {
    cidr_block           = var.cidr_vpc
    instance_tenancy     = var.instance_tenancy
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = var.nombre_vpc
    }
}

# Subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "subnet" {
    count                = length(var.subnets)
    availability_zone    = var.subnets[count.index].subnet_az_name # (Optional) The AZ for the subnet.
    availability_zone_id = var.subnets[count.index].subnet_az_id # (Optional) The AZ ID of the subnet.
    cidr_block           = var.subnets[count.index].subnet_cidr # (Required) The CIDR block for the subnet.
    vpc_id               = aws_vpc.vpc.id # (Required) The VPC ID.
    tags = { # (Optional) A map of tags to assign to the resource.
        name = var.subnets[count.index].subnet_name
    }
}


# Gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.nombre_vpc}_gateway"
  }
}

# Tablas de Ruta
# Router
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "router" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.nombre_vpc}_router"
  }
}

# Rutas
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
resource "aws_route" "ruta_internet" {
    route_table_id = aws_route_table.router.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

# Al router le pincho las subredes. Vincular tablas de ruta
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "conexion_subredes" {
  count          = length(aws_subnet.subnet)
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.router.id
}


locals {  # CONSTANTES
    ingress = { 
        "ssh": {
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        },
        "http": {
            from_port   = 8080
            to_port     = 8080
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        },
        "mariadb": {
            from_port   = 3306
            to_port     = 3306
            protocol    = "tcp"
            cidr_blocks = ["10.0.1.0/24"]
        }
    }
}

# SecurityGroups
# Crear security group para conectarnos a la máquina
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "security_group" {
  name        = "${var.nombre_vpc}_sg"
  description = "security group para la VPC ${var.nombre_vpc}"
  dynamic "ingress" {
      iterator = ingress_actual
      for_each = local.ingress
      content {
            from_port   = ingress_actual.value["from_port"]
            to_port     = ingress_actual.value["to_port"]
            protocol    = ingress_actual.value["protocol"]
            cidr_blocks = ingress_actual.value["cidr_blocks"]
      }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# OUTPUT DEL SECURITY_GROUP.ID
output "security_group_id"{
    value = [ aws_security_group.security_group.id ]
}