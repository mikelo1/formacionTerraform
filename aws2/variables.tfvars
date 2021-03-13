nombre_maquina="MaqMikel"
region_aws="eu-west-1"
id_clave="mi-clave-mikel"
nombre_vpc="mikel_vpc"
cidr_vpc="10.0.0.0/16"
subnets= [
    {
        "subnet_name": "mikel_publica",
        "subnet_cidr": "10.0.1.0/24",
        "subnet_az_name": null,
        "subnet_az_id": null,
        "subnet_public": true
    },
    {
        "subnet_name": "mikel_privada",
        "subnet_cidr": "10.0.2.0/24",
        "subnet_az_name": null,
        "subnet_az_id": null,
        "subnet_public": false
    }
]