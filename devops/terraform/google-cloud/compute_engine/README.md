# Google Folders

### Terraform tfvars

Son archivos en formato JSON (`terraform.tfvars.json`) donde se especifican los ajustes necesarios para conectarse a Google Cloud, ubicación de archivos de datos y ajustes específicos para cada recurso. Tiene la siguiente estructura:

```json
{
    "config": {
        "credentials_path": "Ruta al archivo de credenciales para autenticar con Google Cloud",
        "definitions_path": "ruta al directorio que contiene las definiciones de esquema, temas o suscripciones"
    }
}
```

> [!NOTE]
> Es necesario especificar el archivo al momento de realizar un `plan` o `apply`, esto se realiza especificando la opción `--var-file`.

### Terraform state

Los estados de los recursos serán almacenados en un bucket en GCP para poder visualizar el cambio de estos y su versionamiento, sera necesario especificar la configuración del backend de terraform por medio de un archivo `hcl` y con la opción de `backend-config` (Véase la sección de [Comandos y Variables/Opciones](#comandos-y-variablesopciones-de-input-utilizados)).

Este archivo deberá tener la siguiente estructura:

```json
bucket=nombre del bucket
prefix=ubicación donde se almacenará el estado
credentials=credenciales que se utilizarán para acceder al bucket (ejemplo: terraform/state, terraform/topic/state, terraform/schema/state, etc.)
```

### Definiciones de recursos

Son archivos en formato JSON (`somename.json`) donde se especifican las definiciones con las que se crearan los recursos. Tiene la siguiente estructura:

```json
{
    "compute_instances": [
        {
            "name": "Nombre que llevará la instancia",
            "zone": "Zona donde se ubicará la instancia",
            "project_id": "Proyecto donde se ubicará la instancia",
            "machine_type": "Tipo de maquina que se creará",
            "allow_stopping_for_update": "Booleano para especificarle a terraform que detenga la instancia antes de actualizar alguna propiedad",
            "can_ip_forward": "Booleano para permitir el envío de paquetes",
            "deletion_protection": "Booleano para habilitar la protección para borrar la instancia, si se habilita es necesario deshabilitarla desde la consola antes de correr el terraform",
            "enable_display": "Booleano para habilitar la pantalla virtual",
            "tags": "Listado de etiquetas de red para asignar a la instancia",
            "auto_delete": "Booleano para especificar si el disco duro se borrará en automático cuando se elimine la instancia",
            "image": "Imagen con la que inicializará la instancia",
            "size": "Tamaño de la imagen en gigabytes",
            "type": "Tipos de disco duro, pueden ser pd-standard, pd-balanced or pd-ssd",
            "mode": "Modo en que se asignará el disco duro, puede ser READ_WRITE o READ_ONLY",
            "queue_count": "Recuento de colas de red, por default 0",
            "on_host_maintenance": "Asigna el comportamiento para el mantenimiento de la instancia, las opciones pueden ser MIGRATE o TERMINATE",
            "preemptible": "Booleano para especificar si la instancia es preferible, si se pone en true este campo es necesario poner en false la propiedad automatic_restart",
            "provisioning_model": "Especifica el tipo de preferencia que tendrá la instancia, los valores pueden ser STANDARD o SPOT",
            "enable_integrity_monitoring": "Booleano para habilitar la comparación de integridad de propiedades, es necesario habilitar la propiedad allow_stopping_for_update",
            "enable_secure_boot": "Booleano para habilitar la verificación de la firma digital de todos los componentes, es necesario habilitar la propiedad allow_stopping_for_update",
            "enable_vtpm": "Booleano para habilitar el modulo virtual de confianza (se usa para encriptar llaves y certificados), es necesario habilitar la propiedad allow_stopping_for_update",
            "labels": "Mapa en forma de llave/valor para asignar a la instancia",
            "metadata": "Metadatos en forma de llave/valor para asignar a la instancia, en esta propiedad se agregan las llaves ssh para acceso a la instancia (llave ssh-keys)",
            "stack_type": "Tipo de interfaz de red que tendrá la instancia, los valores pueden ser IPV4_IPV6 o IPV4_ONLY",
            "subnetwork": "Nombre de subred/vpc que se asignará a la instancia, tiene que ser en el siguiente formato projects/{id del proyecto}/regions/{región de la instancia}/subnetworks/{nombre de la subred}",
            "automatic_restart": "Booleano para especificar si la instancia se reiniciará automáticamente si fue terminada por el Compute Engine(no un usuario)",
            "sa_account_id": "Id de la cuenta de servicio que se creará para la instancia",
            "sa_display_name": "Nombre/descripción que se mostrara de la cuenta de servicio",
            "scopes": "Lista de servicios que tendra alcance la cuenta de servicio, para dar acceso a todos los API's de la nube poner cloud-plataform"
        }, ...
    ]
}
```

> [!TIP]
> Si desean conocer mas atributos o tener una descripción mas detallada de los que se usan en las definiciones pueden ir a la [documentación publicada](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance).

### Comandos y Variables/Opciones de input utilizados

**Variables/Opciones**, son utilizadas para especificarle a los comandos de terraform donde guardar archivos generados o que archivos debe utilizar. Las que utilizaremos son:

-   **TF_DATA_DIR**, sirve para especificar el directorio donde se guardaran los estados de los recursos e instalación de plugins de proveedores, es necesario especificarlo antes de ejecutar algún comando.
-   **var-file**, sirve para especificar el archivo que contiene las variables necesarias para la ejecución de los archivos de terraform (`.tfvars.json`).
-   **backend-config**, sirve para especificar el archivo que contiene la configuración para almacenar el estado de los recursos en la nube (aplica solo en el comando `init`).
-   **chdir**, sirve para especificar el directorio de trabajo antes de ejecutar cierto comando (Ejemplo: `terraform -chdir=DIRECTORIO plan`), se puede usar para cuando no se quiera navegar hasta la ubicación de los archivos de terraform.

**Comandos**, son utilizados para inicializar, visualizar y crear los recursos que se ocupan crear. Los que utilizaremos son:

-   **init**, prepara el directorio de trabajo para poder ejecutar los otros comandos. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/folder init -backend-config=ubicacion_configuracion_backend`
-   **plan**, muestra los cambios del recurso que se van a ejecutar. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/folder plan -var-file=ubicacion_tfvars`
-   **apply**, actualiza los cambios en el recurso. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/folder apply -var-file=ubicacion_tfvars`
-   **destroy**, elimina los recursos especificados. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/folder destroy -var-file=ubicacion_tfvars`

> [!TIP]
> Si desean conocer más sobre las diferentes opciones y comandos disponibles pueden acudir a la [documentación publicada](https://developer.hashicorp.com/terraform/cli/commands).
