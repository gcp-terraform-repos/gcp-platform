# Onboarding a new repo

This is the full, step-by-step version of the README's "Onboarding a new
repo" section, with the reasoning behind each step.

## Prerequisites

- gcp-platform's own `bootstrap/` has already been applied at least once
  (it's a shared, org-wide dependency -- check with whoever runs the
  platform, or see [Bootstrap lifecycle](architecture/bootstrap-lifecycle.md)).
- The new repo has its own dedicated GCP project. This platform is
  **one project per repo, not shared runtime infra** -- a new repo never
  reuses another repo's project.

## The flow

```mermaid
sequenceDiagram
    participant Repo as New repo's bootstrap/
    participant Platform as gcp-platform (this repo)
    participant Proj as New repo's own GCP project
    participant Op as Operator (human)
    participant GH as New repo's GitHub Actions

    Repo->>Platform: module "bootstrap" {<br/>source = git::...//modules/repo-bootstrap?ref=vX.Y.Z<br/>}
    Op->>Proj: tofu apply (local, first time)
    Proj-->>Proj: enables required APIs
    Proj-->>Proj: creates the new repo's own state bucket
    Proj-->>Proj: creates &lt;repo&gt;-ci service account,<br/>trusting gcp-platform's shared pool<br/>for THIS repo only
    Proj-->>Op: tofu output github_variables_command
    Op->>GH: run the printed gh variable set commands
    Note over GH: GCP_PROJECT_ID, GCP_REGION,<br/>WIF_PROVIDER, CI_SERVICE_ACCOUNT
    GH->>Proj: subsequent applies authenticate via WIF,<br/>no human needed
```

## Step by step

**1. Create the new repo's own GCP project.**

```bash
gcloud projects create YOUR_NEW_PROJECT --name="Your New Project"
gcloud billing projects link YOUR_NEW_PROJECT --billing-account=YOUR_BILLING_ACCOUNT_ID
```

**2. In the new repo's `bootstrap/`, call `modules/repo-bootstrap`, pinned
to a tag:**

```hcl
module "bootstrap" {
  source = "git::https://github.com/gcp-terraform-repos/gcp-platform.git//modules/repo-bootstrap?ref=v1.2.2"

  project_id    = var.project_id           # the NEW repo's own project, not the hub
  github_owner  = "gcp-terraform-repos"
  github_repo   = "the-new-repo"
  activate_apis = [ /* whatever this repo's environments need, e.g. run.googleapis.com */ ]
  ci_roles      = [ /* whatever this repo's CI needs to apply, e.g. run.admin */ ]

  # Pick ONE WIF resolution mode -- see below.
  wif_pool_name     = var.wif_pool_name
  wif_provider_name = var.wif_provider_name
}
```

!!! tip "Pin `?ref=` to a tag, never `main`"
    A breaking change in `gcp-platform` should require each consumer to
    opt in by bumping the ref, not silently inherit it on the next apply.
    See [`CHANGELOG.md`](https://github.com/gcp-terraform-repos/gcp-platform/blob/main/CHANGELOG.md)
    for what changed in each tag.

See [`examples/new-repo-bootstrap/`](https://github.com/gcp-terraform-repos/gcp-platform/tree/main/examples/new-repo-bootstrap)
for a complete, runnable version of this file, including both WIF
resolution modes side by side.

**3. Resolve the WIF pool -- pick one:**

=== "String passthrough (default, recommended)"

    Copy `wif_pool_name` / `wif_provider_name` from gcp-platform's
    `bootstrap` outputs as plain strings into your `terraform.tfvars`.
    Needs no permission on the hub project at all.

=== "Data-source lookup"

    Pass `hub_project_id = "gcp-platform-hub"` instead. Needs
    `roles/iam.workloadIdentityPoolViewer` (BETA) granted to whoever runs
    this repo's `bootstrap/` apply, on the hub project. Trades one
    copy-paste step for a hard dependency on hub availability at plan time.

**4. Apply locally, once:**

```bash
cd bootstrap
tofu init
tofu apply
```

**5. Wire up GitHub Actions -- run the printed command:**

```bash
tofu output -raw github_variables_command
# prints something like:
#   gh variable set GCP_PROJECT_ID     --repo gcp-terraform-repos/the-new-repo --body '...'
#   gh variable set GCP_REGION         --repo gcp-terraform-repos/the-new-repo --body '...'
#   gh variable set WIF_PROVIDER       --repo gcp-terraform-repos/the-new-repo --body '...'
#   gh variable set CI_SERVICE_ACCOUNT --repo gcp-terraform-repos/the-new-repo --body '...'
```

None of these four values are sensitive -- they're repo *variables*, not
secrets. No service account key, no GitHub secret, is ever created.

**6. Add a GitHub Actions workflow that authenticates the same way
gcp-platform's own does:**

```yaml
permissions:
  contents: read
  id-token: write

steps:
  - uses: google-github-actions/auth@v2
    with:
      workload_identity_provider: ${{ vars.WIF_PROVIDER }}
      service_account: ${{ vars.CI_SERVICE_ACCOUNT }}
```

From here, that repo's CI can `tofu apply` (or `gcloud`, or trigger Cloud
Build) against its own project, with access bounded exactly to what
`ci_roles` granted -- see [GCP IAM explained](gcp-iam.md) for what's
actually enforcing that boundary.

## Lower-level: calling `ci-service-account` directly

If a repo wants *only* the CI identity -- for example, it shares a state
bucket with another repo and doesn't need `repo-bootstrap`'s bundled state
bucket -- call `modules/ci-service-account` directly instead. See its
[module reference](modules.md#ci-service-account) for the smaller surface
area that exposes.
