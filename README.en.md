# gcp-terraform-project-factory

Reference repository for **creating and managing Google Cloud Platform (GCP) projects in an automated way** using Terraform as Infrastructure as Code (IaC), driven by a single declarative source of truth in JSON.

> 🌎 Español: [`README.md`](README.md)

> **Note:** This is a generic *skeleton* with **dummy** data. It contains no real information from any organization. Replace the placeholders (`your-org`, `example-tfstate-bucket`, IDs like `100000000001`, billing `000000-000000-000000`, `@your-github-username`, etc.) with your own values before using it.

## Purpose

Automate the creation and configuration of GCP projects —folders, projects, API enablement, and service accounts— avoiding the manual, error-prone work of doing it by hand in the GCP web console. Infrastructure is described declaratively in a JSON file and Terraform provisions it in a massive, reproducible way.

See [`docs/benefits-analysis.en.md`](docs/benefits-analysis.en.md) for an estimate of time savings versus the manual method, plus the pros and cons of the approach.

## How it works (architecture)

```
platforms/definitions/project.json   <- source of truth (folders, projects, services, SAs)
              │  (fileset + jsondecode + for_each)
              ▼
devops/terraform/google-cloud/gcp_project_factory   <- orchestrator module
              │  composes in cascade:
              ├─ folder/            -> google_folder
              ├─ project/           -> google_project
              ├─ project_services/  -> google_project_service
              └─ service_account/   -> google_service_account (+ keys)
```

The module reads the JSON directly with `fileset()` + `jsondecode()` and creates resources with `for_each`. **There is no code generation or intermediate templating**: the JSON *is* Terraform's input. State is stored in a remote GCS backend (see `platforms/variables/backend.hcl`).

## Getting Started

### Prerequisites

- Git
- Terraform installed locally (for testing) or a CI runner
- A GCP service account with permissions to create folders/projects/SAs
- GCP credentials (the SA key) placed at `credentials/credentials.json` (this path is in `.gitignore`; **never** commit the key)

### Workflow (GitOps)

1. **Create a new branch based on main**

    ```bash
    git checkout main
    git pull origin main
    git checkout -b feature/your-feature-name
    ```

2. **Edit the configuration file**

    - Edit `platforms/definitions/project.json` (add folders/projects/services/service accounts).

3. **Commit your changes**

    ```bash
    git add .
    git commit -m "feat: add new project/configuration"
    git push origin feature/your-feature-name
    ```

4. **Open a Merge/Pull Request**
    - Open a MR/PR and request review (see `CODEOWNERS`).
    - The pipeline validates labels and runs `terraform plan`.
    - Once approved and merged to `main`, `terraform apply` runs.

## CI/CD pipeline

Defined in `.gitlab-ci.yml` with 3 stages:

1. **`label-checker`** (`.gitlab-scripts.yml`): validates via `git diff` + `jq` that every new project has the mandatory `bu` and `environment` labels; otherwise the pipeline fails (governance).
2. **`terraform-plan`** (`devops/ci-cd/terraform/.gitlab-plan.yml`): `terraform init` + `plan` on any branch/MR.
3. **`terraform-apply`** (`devops/ci-cd/terraform/.gitlab-applyer.yml`): `terraform apply -auto-approve`, only on `main`. Optionally assigns roles to the generated SAs if `BIND_SERVICE_ACCOUNTS=true`.

> The terraform jobs are included as *local mirrors* so the repo is self-contained. In a real setup they usually live in a shared DevOps repo (`include: project: your-org/DevOps`).

## Project configuration

### Structure of `platforms/definitions/project.json`

Defines the GCP project configuration with four sections:

#### `folders`
GCP folder hierarchy.
- `name`: Folder name
- `parent`: Parent type (e.g. `"folder"` or `"organization"`)
- `parent_id`: Numeric parent ID in GCP

#### `projects`
GCP projects to create.
- `name`: Project name/ID
- `folder_name`: Folder where it is created (or a direct `folder_id`)
- `auto_create_network`: Create the default network (`"true"`/`"false"`)
- `billing_account`: Associated billing account
- `labels`: Labels (must include `bu` and `environment`)

#### `project_services`
GCP APIs to enable per project.
- `project_id`: Target project
- `gcp_service_list`: List of APIs (e.g. `serviceusage.googleapis.com`, `cloudresourcemanager.googleapis.com`)

#### `service_accounts`
Service accounts to create.
- `name`: Base name (a `-sa` suffix is appended)
- `project_id`: Project where it is created

### Example (dummy data)

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

## Available modules

Besides the `gcp_project_factory` orchestrator, `devops/terraform/google-cloud/` contains reusable modules for common resources: `folder`, `project`, `project_services`, `service_account`, `iam/group`, `resource_binding/*`, `cloud_run`, `cloud_function`, `cloud_sql`, `compute_engine`, `bigquery_dataset`, `bigquery_table`, `bigtable_table`, `pubsub/*`, `storage_bucket`, `artifact_registry_repository`, `apigee`, `dataflow_job`, `eventarc_trigger_to_cloudrun`, `events_framework`.

## License

MIT — see [`LICENSE`](LICENSE). Reference project, non-commercial.
