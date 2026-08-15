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
  ci-service-account/   reusable: a repo-scoped CI service account + binding, called from EVERY consuming repo's own bootstrap
```

`bootstrap/` here follows the same local-state-then-migrate pattern as every other repo in the org: applied with local state first, then `tofu init -migrate-state` into the bucket it just created.

## How a new repo consumes this

In the new repo's own `bootstrap/`:

```hcl
module "ci_identity" {
  source = "git::https://github.com/gcp-terraform-repos/gcp-platform.git//modules/ci-service-account?ref=v1.0.0"

  project_id    = var.project_id       # the NEW repo's own project, not this hub
  account_id    = "<repo>-ci"
  display_name  = "<Repo> CI/CD"
  wif_pool_name = var.wif_pool_name    # from this repo's `wif_pool_name` output
  github_repo   = "the-new-repo"
  roles         = [ /* whatever that repo's CI needs */ ]
}
```

Pin `?ref=` to a tag, never `main` — a breaking change here should require each consumer to opt in by bumping the ref, not inherit it silently on their next apply.

## Commands

```bash
tofu fmt -recursive
cd bootstrap && tofu init -backend=false && tofu validate

# Normal workflow, once the hub project exists
tofu init
tofu apply
tofu output -raw wif_pool_name
tofu output -raw wif_provider_name
```

No tests beyond `tofu validate` and a `plan` against the real hub project.

## Releasing a new module version

1. Change `modules/ci-service-account/`.
2. `tofu fmt -recursive` + `tofu validate`.
3. Tag: `git tag vX.Y.Z && git push origin vX.Y.Z`.
4. Update the `?ref=` in each consuming repo deliberately, one at a time — this is the safety valve versioning buys you.
