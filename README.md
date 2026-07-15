# gcp-terraform-project-factory

Repositorio de referencia para **crear y gestionar proyectos de Google Cloud Platform (GCP) de forma automatizada** usando Terraform como Infraestructura como Código (IaC), a partir de una única fuente de verdad declarativa en JSON.

> 🌎 English: [`README.en.md`](README.en.md)

> **Nota:** Este es un *cascarón* (skeleton) genérico con datos **dummy**. No contiene información real de ninguna organización. Reemplaza los placeholders (`your-org`, `example-tfstate-bucket`, IDs `100000000001`, billing `000000-000000-000000`, `@your-github-username`, etc.) por tus valores antes de usarlo.

## Propósito

Automatizar la creación y configuración de proyectos en GCP —folders, proyectos, habilitación de APIs y cuentas de servicio— evitando el trabajo manual y propenso a error de hacerlo a mano en la consola web de GCP. La infraestructura se describe declarativamente en un JSON y Terraform la genera de forma masiva y reproducible.

Consulta [`docs/analisis-beneficios.md`](docs/analisis-beneficios.md) ([English](docs/benefits-analysis.en.md)) para una estimación de la reducción de tiempos frente al método manual, y los pros y contras del enfoque.

## Cómo funciona (arquitectura)

```
platforms/definitions/project.json   <- fuente de verdad (folders, projects, services, SAs)
              │  (fileset + jsondecode + for_each)
              ▼
devops/terraform/google-cloud/gcp_project_factory   <- módulo orquestador
              │  compone en cascada:
              ├─ folder/            -> google_folder
              ├─ project/           -> google_project
              ├─ project_services/  -> google_project_service
              └─ service_account/   -> google_service_account (+ keys)
```

El módulo lee el JSON directamente con `fileset()` + `jsondecode()` y crea los recursos con `for_each`. **No hay generación de código ni plantillas intermedias**: el JSON *es* la entrada de Terraform. El estado se guarda en un backend remoto de GCS (ver `platforms/variables/backend.hcl`).

## Getting Started

### Prerrequisitos

- Git
- Terraform instalado localmente (para pruebas) o un runner de CI
- Una cuenta de servicio de GCP con permisos para crear folders/projects/SAs
- Credenciales de GCP (clave de la SA) colocadas en `credentials/credentials.json` (esta ruta está en `.gitignore`; **nunca** subas la llave al repo)

### Flujo de trabajo (GitOps)

1. **Crear una nueva rama basada en main**

    ```bash
    git checkout main
    git pull origin main
    git checkout -b feature/nombre-de-tu-feature
    ```

2. **Modificar el archivo de configuración**

    - Edita `platforms/definitions/project.json` (agrega folders/proyectos/servicios/cuentas de servicio).

3. **Realizar cambios y commit**

    ```bash
    git add .
    git commit -m "feat: agregar nuevo proyecto/configuración"
    git push origin feature/nombre-de-tu-feature
    ```

4. **Crear Merge/Pull Request**
    - Abre un MR/PR y solicita revisión (ver `CODEOWNERS`).
    - El pipeline valida labels y ejecuta `terraform plan`.
    - Una vez aprobado y fusionado a `main`, se ejecuta `terraform apply`.

## Pipeline de CI/CD

Definido en `.gitlab-ci.yml` con 3 etapas:

1. **`label-checker`** (`.gitlab-scripts.yml`): valida vía `git diff` + `jq` que todo proyecto nuevo tenga los labels obligatorios `bu` y `environment`; de lo contrario falla el pipeline (gobernanza).
2. **`terraform-plan`** (`devops/ci-cd/terraform/.gitlab-plan.yml`): `terraform init` + `plan` en cualquier rama/MR.
3. **`terraform-apply`** (`devops/ci-cd/terraform/.gitlab-applyer.yml`): `terraform apply -auto-approve`, solo en `main`. Opcionalmente asigna roles a las SAs generadas si `BIND_SERVICE_ACCOUNTS=true`.

> Los jobs de terraform están incluidos como *mirrors locales* para que el repo sea autocontenido. En un setup real suelen vivir en un repo de DevOps compartido (`include: project: your-org/DevOps`).

## Configuración de Proyectos

### Estructura de `platforms/definitions/project.json`

Define la configuración de los proyectos de GCP y contiene cuatro secciones:

#### `folders`
Jerarquía de carpetas en GCP.
- `name`: Nombre de la carpeta
- `parent`: Tipo de padre (ej: `"folder"` u `"organization"`)
- `parent_id`: ID numérico del padre en GCP

#### `projects`
Proyectos de GCP a crear.
- `name`: Nombre/ID del proyecto
- `folder_name`: Carpeta donde se crea (o `folder_id` directo)
- `auto_create_network`: Crear red por defecto (`"true"`/`"false"`)
- `billing_account`: Cuenta de facturación asociada
- `labels`: Etiquetas (deben incluir `bu` y `environment`)

#### `project_services`
APIs de GCP a habilitar por proyecto.
- `project_id`: Proyecto destino
- `gcp_service_list`: Lista de APIs (ej: `serviceusage.googleapis.com`, `cloudresourcemanager.googleapis.com`)

#### `service_accounts`
Cuentas de servicio a crear.
- `name`: Nombre base (se le aplica el sufijo `-sa`)
- `project_id`: Proyecto donde se crea

### Ejemplo (datos dummy)

```json
{
    "folders": [
        { "name": "demo", "parent": "folder", "parent_id": "100000000001" }
    ],
    "projects": [
        {
            "name": "demo-app-prod",
            "folder_name": "demo",
            "auto_create_network": "false",
            "billing_account": "000000-000000-000000",
            "labels": { "environment": "prod", "bu": "demo" }
        }
    ],
    "project_services": [
        {
            "project_id": "demo-app-prod",
            "gcp_service_list": [
                "serviceusage.googleapis.com",
                "cloudresourcemanager.googleapis.com",
                "run.googleapis.com"
            ]
        }
    ],
    "service_accounts": [
        { "name": "main-demo-app", "project_id": "demo-app-prod" }
    ]
}
```

## Módulos disponibles

Además del orquestador `gcp_project_factory`, en `devops/terraform/google-cloud/` hay módulos reutilizables para recursos comunes: `folder`, `project`, `project_services`, `service_account`, `iam/group`, `resource_binding/*`, `cloud_run`, `cloud_function`, `cloud_sql`, `compute_engine`, `bigquery_dataset`, `bigquery_table`, `bigtable_table`, `pubsub/*`, `storage_bucket`, `artifact_registry_repository`, `apigee`, `dataflow_job`, `eventarc_trigger_to_cloudrun`, `events_framework`.

## Licencia

MIT — ver [`LICENSE`](LICENSE). Proyecto de referencia sin fines comerciales.
