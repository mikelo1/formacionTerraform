
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
variable "aws_ami_mas_reciente" {
    description = "Tomar imagen mas reciente"
    type = bool
    default = true
}
variable "aws_ami_id" {
    description = "Id de la imagen a utilizar"
    type = string
    default = ""
}

variable "volumenes" {
    description = "Id de la imagen a utilizar"
    type = map(list(string))
    default = {}
}

variable "nombre_clave" {
    description = "Nombre de la clave"
    type = string
}
variable "tipo_instancia" {
    description = "Tipo de instancia"
    type = string
    default = "t2.micro"
}
variable "nombre_maquina" {
    description = "Nombre de la imagen a utilizar"
    type = string
}
variable "security_groups" {
    description = "Lista de identificadores de security groups"
    type = list(string)
}
