# Google EventArc Triggers To Cloudrun

### Terraform tfvars

Son archivos en formato JSON (`terraform.tfvars.json`) donde se especifican los ajustes necesarios para conectarse a Google Cloud, ubicación de archivos de datos y ajustes específicos para cada recurso. Tiene la siguiente estructura:

```json
{
    "config": {
        "project_id": "ID del proyecto en Google Cloud",
        "credentials_path": "Ruta al archivo de credenciales para autenticar con Google Cloud",
        "definitions_path": "ruta al directorio que contiene las definiciones de los triggers",

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

-   **init**, prepara el directorio de trabajo para poder ejecutar los otros comandos. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/ecent_arc_trigger_to_cloudrun init -backend-config=ubicacion_configuracion_backend`
-   **plan**, muestra los cambios del recurso que se van a ejecutar. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/ecent_arc_trigger_to_cloudrun plan -var-file=ubicacion_tfvars`
-   **apply**, actualiza los cambios en el recurso. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/ecent_arc_trigger_to_cloudrun apply -var-file=ubicacion_tfvars`
-   **destroy**, elimina los recursos especificados. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/ecent_arc_trigger_to_cloudrun destroy -var-file=ubicacion_tfvars`

### Posibles problemas
Es posible que te encuentras un error 403 al tratar de generar el recurso, si esto sucede puedes usar el siguiente comando para generar unas claves de servicio con tu cuenta:
```bash
gcloud auth application-default login
```

El json que te genere puedes usarlo para levantar los recursos, tambien no olvides revisar los permisos necesarios en la siguiente [documentación publicada](https://cloud.google.com/eventarc/docs/creating-triggers-terraform?hl=es-419). 


> [!TIP]
> Si desean conocer más sobre las diferentes opciones y comandos disponibles pueden acudir a la [documentación publicada](https://developer.hashicorp.com/terraform/cli/commands).

> [!TIP]
> Recuerda revisar las reglas para nombrar recuross de google [Asigna nombres a recursos](https://cloud.google.com/compute/docs/naming-resources?hl=es-419)

[!TIP]
