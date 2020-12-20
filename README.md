# Cluster GKE privado

Esto define una infraestructura basada en Kubernetes como clúster privado gestionado por Google Kubernetes Engine de Google Cloud Plarform y una Instancia GCE que sirve como bastión SSH para poder acceder al clúster.

El cluster se despliegue en una zona de GCP. No es regional, por tanto no se adapta para desplegar los nodo en diferentes zonas. Está basado para uso con una cuenta de prueba de GCP.

## Dependencias

Se requiere `terraform` v0.12 o superior. Además, se requieren tener `gcloud` y `kubectl` instalados en la máquina local y autorizado para su uso con el proyecto de GCP.

Para el uso correcto de script `bastion` se requiere linux con el comando `ip` instalado para poder asignar un alias a la interfaz local y, desde luego, acceso `root` por sudo para poder hacer tal cosa.

## Preparar el entorno GCloud

Una vez instalado GCloud, autoriza su uso para tu cuenta de GCloud:

``` 
$ gcloud init
```

Necesitarás acceso login a tu cuenta para que se te ofrezca el token de autenticación para tu entorno local.

A continuación, añade tu cuenta al Application Default Credential (ADC). Esto permitirá a Terraform acceso a esas credenciales para aprovisionar los recursos en GCloud.

``` 
$ gcloud auth application-default login
``` 

## Configuración

Crear fichero `terraform.tfvars` similar a este, con los valores apropiados:

```
project_id               = "[PROJECT_ID]"
region                   = "[REGION]"
zone                     = "[ZONE]"
gce_ssh_user             = "[USUARIO]"
```

## Despliegue

Lanzar los siguientes comandos en orden para el despliegue:

```
$ terraform init
$ terraform plan
$ terraform apply
```

## Bastión

Para poder lanzar el bastión y poder hacer uso de `kubectl` desde local.

Desde el directorio donde está el repositorio y se ha ejecutado el despliegue con terraform, ejecutar:

```
$ ./bastion start
```

Para detener el bastión:

```
$ ./bastion stop
```

Una vez ejecutado el bastión se pueden ejecutar comandos sobre k8s con `kubectl`, como por ejemplo `kubectl get pods`.

*Nota*: 
Se requiere acceso `root` a la máquina local para poder ajustar un alias de dirección IP en la intefaz de red.
Adaptar el script con los valores de configuración apropiados para dicha interfaz.

