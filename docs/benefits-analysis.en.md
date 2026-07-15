# Benefits analysis: declarative IaC vs. manual creation in the GCP console

This document justifies this repository's approach —describing GCP infrastructure in a **declarative JSON** that Terraform applies automatically via CI/CD— versus the previous method: **creating every folder, project, API, and service account by hand in the Google Cloud web console**.

> 🌎 Español: [`analisis-beneficios.md`](analisis-beneficios.md)

> All figures are **illustrative estimates** using dummy data. Calibrate them with your team's real measurements.

## 1. Time-savings estimate

### Cost model

- **Manual method (GCP console):**
  `manual_time ≈ num_resources × steps_per_resource × time_per_step`
  Each resource means navigating menus, waiting on provisioning, copying IDs between screens, and eyeballing verification. Time grows **linearly with the number of resources** and with each person who repeats it.

- **IaC method (this repo):**
  `iac_time ≈ json_edit_time + pipeline_time (unattended)`
  Editing the JSON is proportional to the *change*, not to the total infrastructure. The `apply` runs in CI with no human intervention, and the same effort applies to 1 or 100 resources (`for_each`).

### Per-task comparison

| Task | Manual in console | With this repo | Approx. saving |
|---|---|---|---|
| Create 1 project + billing + labels | ~8–12 min (clicks, waits, verification) | ~1–2 min (edit JSON) | ~80% |
| Enable N APIs in a project | ~1 min/API × N (one by one) | included in the JSON, in bulk | ~90% |
| Create service account + key + upload to a bucket | ~10–15 min manual | automatic in the `apply` | ~95% |
| Apply the same change to 10 projects | ~2–3 h (sequential, error-prone) | ~10 min editing + unattended pipeline | ~90% |
| Reproduce a full environment from scratch | Hours/days (no single source) | Re-run the pipeline over the JSON | Very high |
| Audit "what exists and why" | Hard (review the console resource by resource) | Trivial (read the JSON + Git history) | Very high |

### Illustrative scale example

Provisioning **20 projects**, each with 3 APIs and 1 service account:

- **Manual:** `20 × (~10 min project + 3 × ~1 min API + ~12 min SA) ≈ 20 × 25 min ≈ 8.3 hours`, plus the risk of inconsistencies between projects.
- **IaC:** edit the JSON (~30–45 min once) + unattended pipeline. **Estimated saving > 85%**, with an identical, reproducible result.

The biggest benefit is not the one-off saving but that effort stays **nearly constant as you scale** and **repetitive, error-prone manual work is eliminated**.

## 2. Pros

- **Single source of truth**, declarative and versioned in Git: the JSON describes the *entire* desired state.
- **Reproducibility and auditability:** every change is a reviewable diff; history explains the *why*.
- **Linear scale with near-constant effort:** `for_each` over the JSON; adding the 100th project costs about the same as the first.
- **Automated governance:** the `label-checker` forces every new project to carry `bu` and `environment` labels before merging.
- **Less human error:** no manual clicks or values copied by hand across screens.
- **Unattended deployment:** `apply` runs in CI after MR/PR approval.
- **Easy onboarding:** understanding a JSON is faster than learning dozens of console screens.
- **Data/code separation:** the *definitions* (`platforms/`) are separate from the reusable Terraform *modules* (`devops/terraform/`).

## 3. Cons and considerations

- **Initial learning curve:** requires knowing Terraform, remote state, and the CI pipeline.
- **Dependency on the state backend:** state lives in a GCS bucket; losing or corrupting it is critical (enable versioning and restricted access).
- **Deployer service account with broad permissions:** a sensitive target; apply least privilege and key rotation.
- **Service account key handling:** the flow generates SA keys and uploads them to a bucket. This is a **point to harden**: prefer Workload Identity Federation or avoid long-lived keys when possible.
- **A very large JSON can become hard to maintain:** mitigable by splitting it into several files (`fileset` supports multiple `*.json` in the definitions directory).
- **`terraform apply -auto-approve` on `main`:** demands MR/PR review discipline and solid prior `plan`s, since it applies with no manual confirmation.
- **Inherited observation from the original:** the role binding in `.gitlab-applyer.yml` uses inconsistent variable names (`$sa_roles`/`$ROLE` vs. `SERVICE_ACCOUNTS_ROLES`/`$role`), so it likely does not assign roles as expected. Worth fixing before serious use.

## 4. Conclusion

The IaC-by-JSON approach shifts the cost of operating infrastructure from **linear and manual** to **near-constant and automated**, bringing reproducibility, auditing, and governance. The price is an initial learning curve and the need to harden state and credential management. For any organization managing more than a handful of GCP projects, the return on investment is fast.
