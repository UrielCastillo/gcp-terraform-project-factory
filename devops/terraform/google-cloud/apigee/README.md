# Terraform Apigee

Apigee es la plataforma de administración de API nativa de Google Cloud que se puede usar para compilar, administrar y proteger APIs en cualquier caso de uso, entorno o escala. Apigee admite REST, gRPC, SOAP y GraphQL.

### Terraform tfvars

Son archivos en formato JSON (`terraform.tfvars.json`) donde se especifican los ajustes necesarios para conectarse a Google Cloud, ubicacion de archivos de datos y ajustes especificos para cada recurso. Tiene la siguiente estructura:

```json
{
    "config": {
        "credentials_path": "Ruta al archivo de credenciales para autenticar con Google Cloud",
        "definitions_path": "Ruta al directorio que contiene las definiciones de esquema, temas o suscripciones"
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
    "apigee": [
        {
            "range_name": "Nombre del rango de IP's de Apigee",
            "purpose": "Descripción del objetivo",
            "address_type": "Forma en la que accedes al proxy INTERNAL/EXTERNAL",
            "prefix_length": "Tamaño del prefijo",
            "network": "VPC network configurada para Apigee",       
            "service": "Servicio de Networking de Google Cloud",
            "reserved_peering_ranges": "Rango permitido de direcciones IP",  
            "analytics_region": "Ubicación física donde se almacen datos de estadísticas",
            "project_id": "ID del proyecto de Google Cloud ",
            "instance_name": "Nombre de la instancia",
            "location": "Región de Google Cloud que estás utilizando",
            "org_id" : "ID de la organización de Apigee (mismo ID del proyecto)"
        }, ...
    ]
}
```

### Comandos y Variables/Opciones de input utilizados

**Variables/Opciones**, son utilizadas para especificarle a los comandos de terraform donde guardar archivos generados o que archivos debe utilizar. Las que utilizaremos son:

-   **TF_DATA_DIR**, sirve para especificar el directorio donde se guardaran los estados de los recursos e instalación de plugins de proveedores, es necesario especificarlo antes de ejecutar algún comando.
-   **var-file**, sirve para especificar el archivo que contiene las variables necesarias para la ejecución de los archivos de terraform (`.tfvars.json`).
-   **backend-config**, sirve para especificar el archivo que contiene la configuración para almacenar el estado de los recursos en la nube (aplica solo en el comando `init`).
-   **chdir**, sirve para especificar el directorio de trabajo antes de ejecutar cierto comando (Ejemplo: `terraform -chdir=DIRECTORIO plan`), se puede usar para cuando no se quiera navegar hasta la ubicación de los archivos de terraform.

**Comandos**, son utilizados para inicializar, visualizar y crear los recursos que se ocupan crear. Los que utilizaremos son:

-   **init**, prepara el directorio de trabajo para poder ejecutar los otros comandos. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/cloud_sql init -backend-config=ubicacion_configuracion_backend`
-   **plan**, muestra los cambios del recurso que se van a ejecutar. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/cloud_sql plan -var-file=ubicacion_tfvars`
-   **apply**, actualiza los cambios en el recurso. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/cloud_sql apply -var-file=ubicacion_tfvars`
-   **destroy**, elimina los recursos especificados. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/cloud_sql destroy -var-file=ubicacion_tfvars`

> [!TIP]
> Si desean conocer más sobre las diferentes opciones y comandos disponibles pueden acudir a la [documentación publicada](https://developer.hashicorp.com/terraform/cli/commands).
