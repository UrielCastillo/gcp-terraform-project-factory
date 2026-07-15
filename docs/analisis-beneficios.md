# Análisis de beneficios: IaC declarativa vs. creación manual en la consola de GCP

> 🌎 English: [`benefits-analysis.en.md`](benefits-analysis.en.md)

Este documento justifica el enfoque de este repositorio —describir la infraestructura de GCP en un **JSON declarativo** que Terraform aplica de forma automatizada por CI/CD— frente al método previo: **crear cada folder, proyecto, API y cuenta de servicio a mano en la consola web de Google Cloud**.

> Todas las cifras son **estimaciones ilustrativas** con datos dummy. Ajústalas con mediciones reales de tu equipo.

## 1. Estimación de reducción de tiempos

### Modelo de cálculo

- **Método manual (consola GCP):**
  `tiempo_manual ≈ nº_recursos × pasos_por_recurso × tiempo_por_paso`
  Cada recurso implica navegar menús, esperar aprovisionamientos, copiar IDs entre pantallas y verificar a ojo. El tiempo crece **linealmente con el número de recursos** y con cada persona que lo repite.

- **Método IaC (este repo):**
  `tiempo_iac ≈ tiempo_edición_JSON + tiempo_pipeline (desatendido)`
  Editar el JSON es proporcional al *cambio*, no al total de infraestructura. El `apply` corre en CI sin intervención humana, y el mismo esfuerzo aplica a 1 o a 100 recursos (`for_each`).

### Comparativa por tarea

| Tarea | Manual en consola | Con este repo | Ahorro aprox. |
|---|---|---|---|
| Crear 1 proyecto + billing + labels | ~8–12 min (clics, esperas, verificación) | ~1–2 min (editar JSON) | ~80% |
| Habilitar N APIs en un proyecto | ~1 min/API × N (una por una) | incluido en el JSON, en bloque | ~90% |
| Crear service account + key + subirla a un bucket | ~10–15 min manual | automático en el `apply` | ~95% |
| Aplicar el mismo cambio a 10 proyectos | ~2–3 h (secuencial, propenso a error) | ~10 min de edición + pipeline desatendido | ~90% |
| Reproducir un entorno completo desde cero | Horas/días (no hay fuente única) | Re-ejecutar el pipeline sobre el JSON | Muy alto |
| Auditar "qué existe y por qué" | Difícil (hay que revisar consola recurso a recurso) | Trivial (leer el JSON + historial de Git) | Muy alto |

### Ejemplo ilustrativo de escala

Provisionar **20 proyectos**, cada uno con 3 APIs y 1 service account:

- **Manual:** `20 × (~10 min proyecto + 3 × ~1 min API + ~12 min SA) ≈ 20 × 25 min ≈ 8.3 horas`, más el riesgo de inconsistencias entre proyectos.
- **IaC:** editar el JSON (~30–45 min una sola vez) + pipeline desatendido. **Ahorro estimado > 85%**, con resultado idéntico y reproducible.

El mayor beneficio no es el ahorro puntual, sino que el esfuerzo se mantiene **casi constante al escalar** y se **elimina el trabajo manual repetitivo y propenso a error**.

## 2. Pros

- **Fuente única de verdad** declarativa y versionada en Git: el JSON describe *todo* el estado deseado.
- **Reproducibilidad y auditabilidad:** cada cambio es un diff revisable; el historial explica el *porqué*.
- **Escala lineal con esfuerzo casi constante:** `for_each` sobre el JSON; agregar el proyecto n.º 100 cuesta casi lo mismo que el primero.
- **Gobernanza automatizada:** el `label-checker` obliga a que cada proyecto nuevo tenga labels `bu` y `environment` antes de fusionar.
- **Menos error humano:** sin clics manuales ni valores copiados a mano entre pantallas.
- **Despliegue desatendido:** el `apply` corre en CI tras la aprobación del MR/PR.
- **Onboarding sencillo:** entender un JSON es más rápido que aprender decenas de pantallas de la consola.
- **Separación datos/código:** las *definiciones* (`platforms/`) están separadas de los *módulos* Terraform reutilizables (`devops/terraform/`).

## 3. Contras y consideraciones

- **Curva de aprendizaje inicial:** requiere conocer Terraform, el estado remoto y el pipeline de CI.
- **Dependencia del backend de estado:** el estado vive en un bucket de GCS; su pérdida o corrupción es crítica (habilitar versioning y accesos restringidos).
- **Cuenta de servicio de despliegue con permisos amplios:** es un objetivo sensible; aplicar mínimo privilegio y rotación de llaves.
- **Manejo de llaves de service account:** el flujo genera claves de SA y las sube a un bucket. Es un **punto a endurecer**: preferir Workload Identity Federation o evitar claves de larga vida cuando sea posible.
- **Un JSON muy grande puede volverse difícil de mantener:** mitigable dividiéndolo en varios archivos (`fileset` soporta múltiples `*.json` en el directorio de definiciones).
- **`terraform apply -auto-approve` en `main`:** exige disciplina de revisión de MR/PR y buenos `plan` previos, ya que se aplica sin confirmación manual.
- **Observación heredada del original:** el binding de roles en `.gitlab-applyer.yml` usa nombres de variable inconsistentes (`$sa_roles`/`$ROLE` frente a `SERVICE_ACCOUNTS_ROLES`/`$role`), por lo que probablemente no asigne los roles como se espera. Conviene corregirlo antes de usarlo en serio.

## 4. Conclusión

El enfoque IaC-por-JSON cambia el costo de operar la infraestructura de **lineal y manual** a **casi constante y automatizado**, aportando reproducibilidad, auditoría y gobernanza. El precio es una curva de aprendizaje inicial y la necesidad de endurecer la gestión de estado y credenciales. Para cualquier organización que gestione más de un puñado de proyectos GCP, el retorno de inversión es rápido.
