# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

The shared identity layer for every repo under the `gcp-terraform-repos` GitHub org: one Workload Identity Federation (WIF) pool that lets any repo's GitHub Actions authenticate to GCP without a service account key.

**Use `tofu`, not `terraform`.** File extensions are still `.tf`.

This repo holds no application infrastructure — no Cloud Run, no databases. Just identity plumbing and its own Tofu state bucket.

## Trust model — read before touching `bootstrap/wif.tf`

Two layers, deliberately separate:

1. **The pool trusts the org.** `bootstrap/wif.tf`'s `attribute_condition` checks `assertion.repository_owner == "gcp-terraform-repos"` and nothing more. This is what makes the pool reusable — a new repo never needs to modify this hub project.
2. **Each repo's actual access is bounded downstream**, in that repo's own project, by `modules/ci-service-account`'s `workloadIdentityUser` binding, which names the specific repository (`attribute.repository/gcp-terraform-repos/<repo>`). *This* binding is the real access boundary, not the pool's condition.

**Never remove the `repository_owner` check from the pool** — without it, any GitHub repo on the internet, in any org, could request tokens this pool accepts (the per-SA binding would still stop them from impersonating anything, but it is one guardrail you don't want to rely on alone). **Never grant `workloadIdentityUser` with a `principalSet` broader than one repo** unless that is genuinely intended — it is the only thing standing between "any repo in the org" and "this specific repo."

## Layout

```
bootstrap/          applied once: required APIs, this repo's own state bucket, the WIF pool + provider
modules/
  project-services/    reusable: enables a list of APIs on a project
  tf-state-bucket/     reusable: a private, versioned GCS bucket for one repo's own state, with the free-tier region validation
  wif-lookup/           reusable: resolves the pool/provider resource names, by data-source lookup OR by string passthrough
  ci-service-account/   reusable: a repo-scoped CI service account + binding, called from EVERY consuming repo's own bootstrap
  repo-bootstrap/       reusable: the composite of all four above -- the ONE module a new repo's bootstrap/ should call
examples/
  new-repo-bootstrap/   a complete, runnable repo-bootstrap call, showing both WIF resolution modes
```

`bootstrap/` here follows the same local-state-then-migrate pattern as every other repo in the org: applied with local state first, then `tofu init -migrate-state` into the bucket it just created.

## How a new repo consumes this

**Recommended: `modules/repo-bootstrap`**, which composes everything a new repo needs (required APIs, its own state bucket, and its CI service account) instead of re-deriving that boilerplate by copy-paste:

```hcl
module "bootstrap" {
  source = "git::https://github.com/gcp-terraform-repos/gcp-platform.git//modules/repo-bootstrap?ref=v1.1.0"

  project_id    = var.project_id           # the NEW repo's own project, not this hub
  github_owner  = "gcp-terraform-repos"
  github_repo   = "the-new-repo"
  activate_apis = [ /* whatever else this repo's environments need */ ]
  ci_roles      = [ /* whatever that repo's CI needs */ ]

  # WIF resolution -- pick ONE of these two, see "Two ways to resolve the WIF pool" below:
  wif_pool_name     = var.wif_pool_name     # string passthrough, needs no hub permission
  wif_provider_name = var.wif_provider_name
  # -- or --
  # hub_project_id = "YOUR_HUB_PROJECT"     # data-source lookup, needs workloadIdentityPoolViewer on the hub
}
```

See `examples/new-repo-bootstrap/` for a complete, runnable version of this.

**Lower-level: `modules/ci-service-account`** directly, if a repo wants only the CI identity (e.g. it shares a state bucket with another repo):

```hcl
module "ci_identity" {
  source = "git::https://github.com/gcp-terraform-repos/gcp-platform.git//modules/ci-service-account?ref=v1.1.0"

  project_id    = var.project_id       # the NEW repo's own project, not this hub
  account_id    = "<repo>-ci"
  display_name  = "<Repo> CI/CD"
  wif_pool_name = var.wif_pool_name    # from this repo's `wif_pool_name` output, or wif-lookup's
  github_owner  = "gcp-terraform-repos"
  github_repo   = "the-new-repo"
  roles         = [ /* whatever that repo's CI needs */ ]
}
```

Pin `?ref=` to a tag, never `main` — a breaking change here should require each consumer to opt in by bumping the ref, not inherit it silently on their next apply.

## Two ways to resolve the WIF pool

`modules/wif-lookup` (used internally by `repo-bootstrap`, and callable directly) resolves the pool/provider resource names one of two ways:

1. **String passthrough** (`wif_pool_name` / `wif_provider_name`) — the consumer copies this repo's `wif_pool_name` / `wif_provider_name` outputs as plain strings. **Needs no permission on the hub project.** This is the original, permanently supported design property of this repo — never remove it.
2. **Data-source lookup** (`hub_project_id`) — the consumer looks the pool up directly via `data "google_iam_workload_identity_pool"`. Needs `roles/iam.workloadIdentityPoolViewer` (a BETA-stage role) granted to whoever runs the consumer's `bootstrap/` on the hub project. Convenient when an operator already has that access and doesn't want to hand-copy two strings, but it converts hub availability into a hard dependency of every consumer's plan.

Neither is "the" way. Pick per-repo based on whether the operator can be granted hub read.

## Commands

```bash
tofu fmt -recursive

# Validate every root/module/example -- none need cloud credentials.
for d in bootstrap modules/*/ examples/*/; do
  (cd "$d" && tofu init -backend=false -input=false && tofu validate)
done

# Normal workflow, once the hub project exists
cd bootstrap
tofu init
tofu apply
tofu output -raw wif_pool_name
tofu output -raw wif_provider_name
```

No `plan`/`apply` tests beyond `tofu validate` and a real `plan` against the hub project — the modules have no environments of their own to exercise them, so `examples/` is what keeps their wiring proven coherent (CI validates it on every PR).

## Releasing a new module version

1. Change whichever `modules/` this release touches.
2. `tofu fmt -recursive` + validate everything (see Commands above).
3. Note the change in `CHANGELOG.md`.
4. Tag: `git tag vX.Y.Z && git push origin vX.Y.Z`.
5. Update the `?ref=` in each consuming repo deliberately, one at a time — this is the safety valve versioning buys you.
