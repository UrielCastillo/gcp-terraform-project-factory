# Google Folders

### Terraform tfvars

Son archivos en formato JSON (`terraform.tfvars.json`) donde se especifican los ajustes necesarios para conectarse a Google Cloud, ubicación de archivos de datos y ajustes específicos para cada recurso. Tiene la siguiente estructura:

```json
{
    "config": {
        "credentials_path": "Ruta al archivo de credenciales para autenticar con Google Cloud",
        "definitions_path": "Ruta al directorio que contiene las definiciones de los servicios de Cloud Run"
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
    "cloud_run_services":[
        {
            "project_id": "Id del projecto",
            "cloud_run_location": "Region del servicio de Cloud Run",
            "max_instance_request_concurrency": "Cantidad máxima de solicitudes por instancia",
            "min_instance_count": "Mínimo de instancias",
            "max_instance_count": "Máximo de instancias",
            "cloud_run_image": " Ruta la imagen de docker en Artifact Registry",
            "name": "Nombre del servicio",
            "cpu_limit": "Límite de cpus por instancia",
            "memory_limit": "Límite de memoria por instancia",
            "service_account": "Cuenta de servicio asociada a las revisiones de el servicio de Cloud Run",
            "ingress": "Proporciona la configuración de ingreso para este Servicio. Posibles valores: INGRESS_TRAFFIC_ALL,INGRESS_TRAFFIC_INTERNAL_ONLY,INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER",
            "ports": "Puertos que se les asignara a los contenedores",
            "envs": "Variables de entorno que utilizara el servicio, estas tienen que darse de alta en el Secret Manager del proyecto y debe tener estos atributos: name (nombre de la variable) y version (version que usara de esta)"
        }...
    ]
}
```

> [!TIP]
> Si desean conocer mas atributos o tener una descripción mas detallada de los que se usan en las definiciones pueden ir a la [documentación publicada](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service).

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
