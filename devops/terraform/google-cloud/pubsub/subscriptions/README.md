# Terraform PUB/SUB

Google Cloud Pub/Sub es un servicio de mensajería que permite enviar y recibir mensajes entre aplicaciones independientes. Permite construir sistemas escalables y basados en eventos. Los conceptos fundamentales incluyen:

**Temas (Topics)**: Canales para enviar mensajes. Los publicadores envían mensajes a los temas.

**Suscripciones (Subscriptions)**: Recursos nombrados que representan el flujo de mensajes desde un tema específico a una aplicación que se suscribe.

**Esquemas (Schemas)**: Una característica opcional para hacer cumplir una estructura de mensaje. Los esquemas definen el formato esperado de los mensajes publicados en un tema.

## Definición de archivos

### Terraform files

Un archivo de Terraform, generalmente con la extensión .tf, es un archivo de configuración que define la infraestructura y los recursos que deseas aprovisionar utilizando Terraform. Estos archivos utilizan la sintaxis **HashiCorp Configuration Language (HCL)**.

Se cuenta con un terraform general (`main.tf`) que ejecuta los terraform file especificados para cada recurso que se desea crear, los cuales se ubican en las subcarpetas.

```
.
├── schemas
│   └── schemas.tf
├── subscriptions
│   └── subscriptions.tf
├── topics
│   └── topics.tf
├── main.tf
├── terraform.tfvars.json
└── README.md
```

### Terraform tfvars

Son archivos en formato JSON (`terraform.tfvars.json`) donde se especifican los ajustes necesarios para conectarse a Google Cloud, ubicacion de archivos de datos y ajustes especificos para cada recurso. Tiene la siguiente estructura:

```json
{
    "config": {
        "project_id": "ID del proyecto en Google Cloud",
        "region": "Región de Google Cloud que estás utilizando",
        "zone": "Zona de Google Cloud que estás utilizando",
        "credentials_path": "Ruta al archivo de credenciales para autenticar con Google Cloud",
        "definitions_path": "ruta al directorio que contiene las definiciones de esquema, temas o suscripciones",
        "schema_settings": {
            "prefix": "Prefijo para nombres de esquemas",
            "suffix": "Sufijo para nombres de esquemas"
        },
        "topic_settings": {
            "prefix": "Prefijo para nombres de temas",
            "suffix": "Sufijo para nombres de temas"
        },
        "subscription_settings": {
            "prefix": "Prefijo para nombres de suscripciones",
            "suffix": "Sufijo para nombres de suscripciones",
            "storage_prefix": "Prefijo para nombres de suscripciones de almacenamiento",
            "storage_suffix": "Sufijo para nombres de suscripciones de almacenamiento"
        }
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
    "tables": [
        {
            "name": "Nombre del recurso",
            "type": "El tipo del recurso (PROTOCOL_BUFFER o AVRO)",
            "definition": "La definición de la tabla, ya sea como una ruta de archivo (para PROTOCOL_BUFFER) o como un objeto (para AVRO)"
        },...
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

-   **init**, prepara el directorio de trabajo para poder ejecutar los otros comandos. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/pubsub/subscriptions init -backend-config=ubicacion_configuracion_backend`
-   **plan**, muestra los cambios del recurso que se van a ejecutar. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/pubsub/subscriptions plan -var-file=ubicacion_tfvars`
-   **apply**, actualiza los cambios en el recurso. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/pubsub/subscriptions apply -var-file=ubicacion_tfvars`
-   **destroy**, elimina los recursos especificados. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/pubsub/subscriptions destroy -var-file=ubicacion_tfvars`

> [!TIP]
> Si desean conocer más sobre las diferentes opciones y comandos disponibles pueden acudir a la [documentación publicada](https://developer.hashicorp.com/terraform/cli/commands).
