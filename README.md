# gcp-platform

The shared GCP connection for every repo under [gcp-terraform-repos](https://github.com/gcp-terraform-repos): one Workload Identity Federation pool that lets any repo's GitHub Actions authenticate to GCP with no service account key, plus a reusable module that gives each repo its own scoped CI service account.

```
GitHub Actions (any repo in gcp-terraform-repos)
   │ OIDC token
   ▼
WIF pool "github-pool"                    hub project
   │ trusts: repository_owner == gcp-terraform-repos
   ▼
Per-repo CI service account               repo's OWN project
   │ trusts: attribute.repository == gcp-terraform-repos/<this repo only>
   ▼
gcloud / tofu apply / Cloud Build, scoped to that repo's project
```

See [CLAUDE.md](CLAUDE.md) for the trust model in detail — read it before changing `bootstrap/wif.tf`.

## First-time setup

### 1. Create the hub project

A dedicated GCP project with billing enabled (required to enable APIs, even though everything here is free):

```bash
gcloud projects create YOUR_HUB_PROJECT --name="GCP Platform"
gcloud billing projects link YOUR_HUB_PROJECT --billing-account=YOUR_BILLING_ACCOUNT_ID
```

### 2. Bootstrap

```bash
cd bootstrap
tofu init
tofu apply -var project_id=YOUR_HUB_PROJECT
```

Then migrate state into the bucket it just created: uncomment the `backend "gcs"` block in `bootstrap/main.tf`, fill in the bucket name, and run `tofu init -migrate-state`.

### 3. Note the outputs

```bash
tofu output -raw wif_pool_name
tofu output -raw wif_provider_name
```

Every consuming repo needs these.

## Onboarding a new repo

1. Create its own GCP project (this platform is one-project-per-repo, not shared runtime infra).
2. In that repo's `bootstrap/`, call `modules/repo-bootstrap` from this repo, pinned to a tag — it creates the required APIs, the repo's own state bucket, and its CI service account in one call. See [CLAUDE.md](CLAUDE.md#how-a-new-repo-consumes-this) for the exact block, or copy [`examples/new-repo-bootstrap/`](examples/new-repo-bootstrap/).
3. Apply that repo's bootstrap locally.
4. Run the `github_variables_command` output it prints — it sets `GCP_PROJECT_ID`, `GCP_REGION`, `WIF_PROVIDER`, and `CI_SERVICE_ACCOUNT` as GitHub Actions variables in the consuming repo.

By default (string-passthrough WIF resolution) no step here requires write *or* read access to this hub project — only the two output values, which are not sensitive. See [CLAUDE.md](CLAUDE.md#two-ways-to-resolve-the-wif-pool) if you'd rather use the data-source lookup instead, which trades that property for one less copy-paste step.

## Known trade-offs

- **A real GCP project must exist** to host the pool before anything here can be applied. Nothing has been applied yet as of this repo's creation.
- **One pool total.** If the org ever needs to isolate CI trust boundaries further (e.g. a contractor's repo that should never share a provider with internal repos), that becomes a second pool + provider here, not a change to this one.
