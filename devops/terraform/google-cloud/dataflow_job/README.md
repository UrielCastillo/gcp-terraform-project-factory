# Google dataflow job

### Terraform tfvars

Son archivos en formato JSON (`terraform.tfvars.json`) donde se especifican los ajustes necesarios para conectarse a Google Cloud, ubicación de archivos de datos y ajustes específicos para cada recurso. Tiene la siguiente estructura:

```json
{
    "config": {
        "project_id": "ID del proyecto en Google Cloud",
        "region": "Región de Google Cloud que estás utilizando",
        "zone": "Zona de Google Cloud que estás utilizando",
        "credentials_path": "Ruta al archivo de credenciales para autenticar con Google Cloud",
        "definitions_path": "ruta al directorio que contiene las definiciones de los dataflow",
        "dataflow_job_settings": {
            "prefix": "Prefijo para nombres de dataflow",
            "suffix": "Sufijo para nombres de dataflow",
            "attribute_name": "Nombre del atributo con el cual buscará en los archivos de definiciones"
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
    "dataflows": [
        {
            "name": "Nombre del recurso",
            "template_gcs_path": "Ubicación del Google Cloud Storage para plantilla del Dataflow",
            "temp_gcs_location": "Ubicación donde se guardarán los datos temporales en el Google Cloud Storage",
            "enable_streaming_engine": "Booleano para habilitar o deshabilitar el uso del streaming engine para el job",
            "inputTopic": "El tema de entrada de Pub/Sub desde el que se va a leer",
            "outputTableSpec": "Ubicación de la tabla de salida de BigQuery, en el formato <my-project>:<my-dataset>.<my-table>",
            "dataset_id": "ID del dataset",
            "table_id": "ID de la tabla",
            "deletion_protection": "Booleano para especificar si terraform puede eliminar la instancia (Si se pone en `true` arrojara un error al realizar un `destroy`)",
            "schema": "Estructura en formato JSON para la tabla externa",
            "time_partitioning_type": "Configura el rango de tiempo con el cual se particionara la tabla",
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

-   **init**, prepara el directorio de trabajo para poder ejecutar los otros comandos. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/dataflow_job init -backend-config=ubicacion_configuracion_backend`
-   **plan**, muestra los cambios del recurso que se van a ejecutar. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/dataflow_job plan -var-file=ubicacion_tfvars`
-   **apply**, actualiza los cambios en el recurso. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/dataflow_job apply -var-file=ubicacion_tfvars`
-   **destroy**, elimina los recursos especificados. Ejemplo: `TF_DATA_DIR=/path/.terraform terraform -chdir=./devops/terraform/google-cloud/dataflow_job destroy -var-file=ubicacion_tfvars`

> [!TIP]
> Si desean conocer más sobre las diferentes opciones y comandos disponibles pueden acudir a la [documentación publicada](https://developer.hashicorp.com/terraform/cli/commands).
