# Terraform Events Framework

El Events Framework es un modulo que te creara la infrastructura minima para escuchar eventos de un topico de pubsub y enviarlos a un cloud run que lo procesara, esta ingrastrucutra incluye:

**Cloud run**: Servidor auto escalable gestionado por google que recevira los eventos.

**Eventarc Trigger**: Trigger de Eventarc que se conecta a un topico, y gestiona el lanzamiento de mensajes hacia el cloudrun previamente creado

## Definición de archivos

### Terraform files

Un archivo de Terraform, generalmente con la extensión .tf, es un archivo de configuración que define la infraestructura y los recursos que deseas aprovisionar utilizando Terraform. Estos archivos utilizan la sintaxis **HashiCorp Configuration Language (HCL)**.

Se cuenta con un terraform general (`main.tf`) que ejecuta los terraform file especificados para cada recurso que se desea crear, los cuales se ubican en otros folders de terraform.

```
.
├── google-cloud
│   └── eventarc_trigger_to_cloudrun
│       └── main.tf
│   └── cloud_run
│       └── main.tf
│   └── events_framework
│       ├── topics.tf
│       ├── main.tf
│       ├── terraform.tfvars.json
│       └── README.md

```

### Terraform tfvars

Son archivos en formato JSON (`terraform.tfvars.json`) donde se especifican los ajustes necesarios para conectarse a Google Cloud, ubicacion de archivos de datos y ajustes especificos para cada recurso. Tiene la siguiente estructura:

```json
{
    "config": {
        "project_id": "ID del proyecto en Google Cloud",
        "region": "Región de Google Cloud que estás utilizando",
        "credentials_path": "Ruta al archivo de credenciales para autenticar con Google Cloud",
        "definitions_path": "ruta al directorio que contiene las definiciones de cloudruns y triggers",

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
    "triggers": [
        {
            "name": "Nombre del trigger que sera creado",
            "region": "Region del trigger",
            "project_id": "ID del proyecto",
            "topic_name": "Nombre del topico que ejecutara el trigger",
            "cloud_run_service": "Servicio de cloudrun que recevira los eventos del tirgger",
            "cloud_run_path": "Ruta del cloudrun donde llegara el evento, tipicamente '/' ",
            "cloud_run_region": "Region donde esta ejecutandose el cloudrun",
            "service_account": "Cuenta de servicio que se le asiganara al eventarc trigger"
        },...
    ],
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
            "ingress": "Proporciona la configuración de ingreso para este Servicio. Posibles valores: INGRESS_TRAFFIC_ALL,INGRESS_TRAFFIC_INTERNAL_ONLY,INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
        }...
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

-   **init**, prepara el directorio de trabajo para poder ejecutar los otros comandos. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/pubsub init -backend-config=ubicacion_configuracion_backend`
-   **plan**, muestra los cambios del recurso que se van a ejecutar. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/pubsub plan -var-file=ubicacion_tfvars`
-   **apply**, actualiza los cambios en el recurso. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/pubsub apply -var-file=ubicacion_tfvars`
-   **destroy**, elimina los recursos especificados. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/pubsub destroy -var-file=ubicacion_tfvars`

> [!TIP]
> Si desean conocer más sobre las diferentes opciones y comandos disponibles pueden acudir a la [documentación publicada](https://developer.hashicorp.com/terraform/cli/commands).
