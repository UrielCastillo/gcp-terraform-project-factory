# Guía de commits y ramas (referencia de uso)

> 🌎 English: [`git-workflow.en.md`](git-workflow.en.md)

Esta guía documenta **cómo se usa este repositorio a través de commits**: convenciones de ramas, de
mensajes y ejemplos de las operaciones más comunes. Sirve como referencia para operar el flujo GitOps
del repo (editar el JSON → MR/PR → revisión → merge → `apply`).

> Todos los ejemplos usan **datos dummy** (`demo-app`, `data-platform`, folders `demo`/`platform`/`analytics`,
> billing `000000-000000-000000`). No incluyas nunca datos reales en los mensajes de commit (ver
> [§6 Higiene](#6-higiene-y-prevención-de-fugas)).

## 1. Propósito

En este repo **la fuente de verdad es `platforms/definitions/project.json`**. Casi todo cambio de
infraestructura es una edición a ese archivo. Por eso:

- Cada commit representa un cambio de infraestructura **revisable y auditable** (el diff del JSON *es* el cambio).
- El historial de Git responde "qué se creó, cuándo y por qué".
- Un mensaje de commit claro + una rama bien nombrada hacen que el Merge/Pull Request se revise rápido.

## 2. Convenciones de ramas

Una rama por unidad de trabajo, partiendo siempre de `main` actualizado.

| Tipo | Formato | Cuándo | Ejemplo |
|---|---|---|---|
| Feature | `feature/<descripcion-corta>` | Nuevos proyectos, folders, servicios | `feature/add-demo-app-project` |
| Hotfix | `hotfix/<descripcion-corta>` | Corrección urgente en `main` | `hotfix/fix-demo-labels` |
| Con ticket | `feature/<TICKET>-<descripcion>` | Si usas Jira/tracker | `feature/INFRA-123-add-data-platform` |

**Recomendaciones:**
- Usa `kebab-case` y descripción en inglés corta y específica: `feature/add-analytics-folder`, no `feature/cambios`.
- Una rama = un objetivo. Evita ramas gigantes que mezclan proyectos no relacionados.

**Evita:**
- Ramas libres sin prefijo ni contexto (`pruebas`, `datawarehouse2`, `sandbox_final`).
- Ramas autogeneradas por el editor web (`usuario-main-patch-12345`): edita en local con una rama con nombre.

## 3. Convenciones de mensajes (Conventional Commits)

Formato: `<tipo>: <descripción en imperativo>`. Estandariza en inglés para consistencia.

| Tipo | Uso |
|---|---|
| `feat:` | Agregar proyecto(s), folder(s), servicios o cuentas de servicio |
| `fix:` | Corregir un valor mal puesto (label faltante, `folder_id` incorrecto) |
| `refactor:` | Reorganizar sin cambiar el resultado (renombrar, reordenar) |
| `chore:` | Tareas de mantenimiento (CODEOWNERS, CI, formato) |
| `docs:` | Cambios solo en documentación |

Mapeo operación → tipo:

| Operación en `project.json` | Tipo de commit |
|---|---|
| Agregar proyecto/folder/servicio/SA | `feat:` |
| Agregar labels `bu`/`environment` faltantes | `fix:` |
| Renombrar proyectos / cambiar prefijo | `refactor:` |
| Borrar proyecto en desuso | `refactor:` o `chore:` |
| Cambiar `folder_id` / mover de folder | `fix:` o `refactor:` |
| Actualizar CODEOWNERS / CI | `chore:` |

## 4. Tabla de referencia: operación → rama → commit → cambio

| Operación | Rama de ejemplo | Mensaje de commit | Cambio en `project.json` |
|---|---|---|---|
| Crear folder | `feature/add-demo-folder` | `feat: add demo folder` | Nueva entrada en `folders` |
| Agregar proyecto dev | `feature/add-demo-app-dev` | `feat: add demo-app dev project` | Entrada en `projects` (`demo-app-dev`) |
| Agregar proyecto prod | `feature/add-demo-app-prod` | `feat: add demo-app prod project` | Entrada en `projects` (`demo-app-prod`) |
| Agregar labels faltantes | `hotfix/fix-demo-labels` | `fix: add bu and environment labels to demo-app` | `labels.bu` / `labels.environment` |
| Habilitar APIs | `feature/enable-demo-app-apis` | `feat: enable run and bigquery apis for demo-app` | Entrada/edición en `project_services` |
| Crear service account | `feature/add-demo-app-sa` | `feat: add main-demo-app service account` | Entrada en `service_accounts` |
| Renombrar proyectos | `refactor/rename-demo-prefix` | `refactor: rename demo projects to demo-app-*` | `name`/`project_id` en `projects` |
| Cambiar de folder | `fix/move-data-platform-folder` | `fix: move data-platform to platform folder` | `folder_name`/`folder_id` |
| Borrar proyecto | `refactor/remove-unused-project` | `refactor: remove unused data-platform-sandbox` | Eliminar entradas asociadas |
| Actualizar owners | `chore/update-codeowners` | `chore: update default code owners` | (edita `CODEOWNERS`, no el JSON) |

## 5. Ejemplo de historial de principio a fin

Un `git log --oneline` ilustrativo (más reciente arriba) de cómo se ve el repo en uso, todo con datos dummy:

```
a1b2c3d  chore: update default code owners
b2c3d4e  refactor: remove unused data-platform-sandbox project
c3d4e5f  refactor: rename demo projects to demo-app-* prefix
d4e5f6a  feat: add main-data-platform service account
e5f6a7b  feat: enable bigquery api for data-platform-dev
f6a7b8c  feat: add data-platform dev project under platform folder
a7b8c9d  fix: add bu and environment labels to demo-app-prod
b8c9d0e  feat: add demo-app prod project
c9d0e1f  feat: add demo-app dev project and enable run api
d0e1f2a  feat: add demo, platform and analytics folders
```

Flujo típico por cada uno de esos commits:

```bash
git checkout main && git pull origin main
git checkout -b feature/add-demo-app-dev
# editar platforms/definitions/project.json (agregar el proyecto)
git add platforms/definitions/project.json
git commit -m "feat: add demo-app dev project and enable run api"
git push origin feature/add-demo-app-dev
# abrir Merge/Pull Request y solicitar revisión (ver CODEOWNERS)
```

Tras la aprobación y el merge a `main`, el pipeline ejecuta `terraform apply` automáticamente.

## 6. Higiene y prevención de fugas

Al ser un repo público de referencia, cuida que **ni los commits ni los metadatos** expongan datos reales:

- **Identidad de Git**: configura una identidad no corporativa antes de commitear.
  ```bash
  git config user.name  "Your Name"
  git config user.email "you@example.com"
  ```
  (El nombre y correo del autor quedan en cada commit para siempre.)
- **Mensajes de commit**: no incluyas nombres reales de personas, correos corporativos, nombres de
  proyectos internos, IDs de folder/billing reales ni IPs. Usa datos dummy o genéricos.
- **Contenido**: nunca commitees credenciales ni llaves de service account. La ruta
  `credentials/credentials.json` ya está en `.gitignore`.
- **Antes del primer push**, verifica que no haya fugas:
  ```bash
  git log --pretty='%an <%ae>' | sort -u   # revisa autores/correos
  grep -rniE 'tu-empresa|@tu-dominio|billing-real' .   # ajusta patrones a tu caso
  ```
- Si vas a publicar un repo que tuvo historial real, **empieza un historial nuevo** (`git init` sobre el
  árbol limpio) en lugar de arrastrar los commits antiguos.
