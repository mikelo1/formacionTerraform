# Esta marca va a aparecer SOLO UNA vez
terraform {
    # Los nombres de proveedores los sacamos de la docum. oficial
    # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
        }
        null = {
            source = "hashicorp/null"
        }
    }
}

# Esta marca puede aparecer varias veces, tantas veces como proveedores tenga
# Pueden tener configuración adicional
provider docker {
}
provider null {
}

# Una marca resource para cada recurso de infra que necesitemos
resource "docker_container" "contenedor_nginx" {
    for_each = toset( ["Todd", "James", "Alice", "Dottie"] ) #Crea un mapa { a:"Todd", b:"James", ...
    name     = each.key
    #name = "mi-contenedor-de-nginx"
    image= docker_image.imagen_nginx.latest # el ID de la imagen del contenedor
    provisioner "local-exec" {
        command = "echo ${self.name}=${self.network_data[0].ip_address} >> inventario.txt"
    }
    connection {
        type        = "ssh"
        host        = self.network_data[0].ip_address
        user        = "root"
        password    = "root"
        port        = 22
    }
    provisioner "remote-exec" {
        inline = [
            "echo ${self.name}=${self.network_data[0].ip_address} >> inventario.txt"
            ]
    }
}
# Null resource para ejecutar solamente provisionadores
resource "null_resource" "inventario" {
    provisioner "local-exec" {
        command = "rm -f inventario.txt"
    }
}
# Resource para descargar la imagen
resource "docker_image" "imagen_nginx" {
    name = var.imagen_de_contenedor
}

# Marca para entradas de datos
variable "imagen_de_contenedor" {
    description ="Imagen de contenedor a usar"
    type = string
    default = "rastasheep/ubuntu-sshd"
}


# Marca para generar salidas
output "inventario" {
    #value = values(docker_container.contenedor_nginx)[*].network_data[0].ip_address
    value = join("\n",[for value in docker_container.contenedor_nginx: "${value.name}=${value.ip_address}"])
}