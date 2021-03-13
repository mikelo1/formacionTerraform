
# Variables del provider
variable "region_aws" {
    description = "Region seleccionada del proveedor"
    type = string
    default = true
}

# Variables de la instancia
variable "aws_ami_owners" {
    description = "Owners"
    type = list(string)
    default = []
}
variable "aws_ami_nombre" {
    description = "Nombre de la imagen AWS"
    type = list(string)
    default = []
}
variable "volumenes" {
    description = "Id de la imagen a utilizar"
    type = map(list(string))
    default = {}
}
variable "nombre_maquina" {
    description = "Nombre de la imagen a utilizar"
    type = string
}

# Variables de la pareja de claves
variable "id_clave" {
    description = "Identificador de la clave"
    type = string
}

# Variables de la VPC
variable "nombre_vpc" {
    description = "Este es el nombre de la VPC"
    type = string
}
variable "cidr_vpc" {
    description = "CIDR de la CPV"
    type = string
}
variable "subnets" {
    description = "Subredes que quiero crear en la VPC."
    type = list(map(string)) 
    default = [ ]
}